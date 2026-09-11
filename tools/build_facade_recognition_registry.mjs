import { createHash } from "node:crypto";
import {
  existsSync,
  lstatSync,
  readdirSync,
  readFileSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { dirname, extname, resolve, sep } from "node:path";
import { fileURLToPath } from "node:url";

import {
  assertJsonSchema,
  assertSchemaDocument,
} from "./lib/dependency-free-json-schema.mjs";
import {
  compareSourceKeys,
  invariant,
  sha256File,
  stableJson,
} from "./lib/world-contract.mjs";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const COMPILER_VERSION = "1.14.0";
const CATALOG_SCHEMA = "ti.facade-recognition-catalog/15";
const RUNTIME_SCHEMA = "ti.facade-runtime-registry/15";
const REPORT_SCHEMA = "ti.facade-recognition-validation-report/4";
const ADAPTER_CONTRACT_SCHEMA = "ti.facade-runtime-adapter-contracts/14";
const LOADER_API_VERSION = "ti.facade-runtime-registry-loader/14";
const UNKNOWN_VERSION_POLICY = "reject";
const CATALOG_ID = "treasure-island-physical-building-recognition";
const CATALOG_SCHEMA_REFERENCE = "./facade-recognition-catalog.schema.json";
const SEED_STRATEGY = "immutable_receiver_inventory_physical_units_v1";
const CHECKED_DATE = "2026-09-09";
// A source-only quality acceptance. Original B1 recognition and every capture-time authority remain unchanged.
const B1_RETURNS_ACCEPTANCE_ROOT = "evidence/first-playable/building-1-wing-returns-v2-accepted-2026-09-08-001";
const B1_RETURNS_ACCEPTANCE_PATH = `${B1_RETURNS_ACCEPTANCE_ROOT}/acceptance-receipt.json`;
const B1_RETURNS_ACCEPTANCE_SHA256 = "257f16bc314151054b120c2b87e6f8cb20577f5e4a7201478b58272a65dc23a4";
const B1_RETURNS_ACCEPTANCE_CANONICAL_SHA256 = "327e4e44f0ffcad7e679e40cbc5f555156c37107cfb485ea588a07b26a61c72e";
const ISLE_HOUSE_PARENT = "w1249412094";
const ISLE_HOUSE_PARTS = ["w1282547786", "w1282547787"];
const ISLE_HOUSE_UNIT_ID = `physical-building:${ISLE_HOUSE_PARENT}`;
const ISLE_HOUSE_HIGH_WALL = "building-composite:w1249412094:w1282547786:wall";
const ISLE_HOUSE_LOW_SOURCE = "w1282547787";
const ISLE_HOUSE_LOW_WALL = "building-composite:w1249412094:w1282547787:wall";
const ISLE_HOUSE_LIVE_ADAPTER_PATH = "game/scripts/world/facades/isle_house_composite_repair_variant_c_live_attachment.gd";
const ISLE_HOUSE_REPAIR_FACTORY_PATH = "game/scripts/world/facades/isle_house_composite_repair_variant_c_repair_only_factory.gd";
const ISLE_HOUSE_REVIEWED_FACTORY_PATH = "game/scripts/world/facades/isle_house_composite_repair_variant_c_standalone_v1.gd";
const ISLE_HOUSE_VARIANT_C_CONFIG_PATH = "game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json";
const ISLE_HOUSE_LIVE_REVIEW_RECEIPT_SHA256 = "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8";
const ISLE_HOUSE_REPAIR_SIGNATURE = "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69";
const ISLE_HOUSE_LIVE_SIGNATURE = "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981";
const BUILDING_1_SOURCE = "r16681702";
const BUILDING_1_WALL = "building:r16681702:wall";
const BUILDING_1_TOWER_SOURCE = "w1222720021";
const BUILDING_1_TOWER_WALL = "building:w1222720021:wall";
const BUILDING_1_HERO_ADAPTER_PATH = "game/scripts/world/facades/building_1_hero_model.gd";
const BUILDING_1_HERO_CONFIG_PATH = "game/resources/facades/building_1_hero_model.json";
const BUILDING_1_PUBLIC_FRONT_CONFIG_PATH = "game/resources/facades/building_1_public_front_believability.json";
const BUILDING_1_RUNTIME_ASSET_PATHS = Object.freeze([
  BUILDING_1_HERO_CONFIG_PATH,
  BUILDING_1_PUBLIC_FRONT_CONFIG_PATH,
  "game/resources/materials/world/building_1/building_1_bluegrey_glass.tres",
  "game/resources/materials/world/building_1/building_1_bronze.tres",
  "game/resources/materials/world/building_1/building_1_canopy_underside.tres",
  "game/resources/materials/world/building_1/building_1_light_trim.tres",
  "game/resources/materials/world/building_1/building_1_projecting_base_stone.tres",
  "game/resources/materials/world/building_1/building_1_reveal_shadow.tres",
  "game/resources/materials/world/building_1/building_1_roof_metal.tres",
  "game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres",
  BUILDING_1_HERO_ADAPTER_PATH,
]);
const PACKAGE_SANITIZATION_SOURCE_PROVENANCE_PATH = "discovery/facades/PRECOMMIT_PACKAGE_SANITIZATION_SOURCE_PROVENANCE.json";
const PACKAGE_SANITIZATION_SOURCE_PROVENANCE_SHA256 = "269558b49e21c6c4f46c7133c3aa6012ca35bc122739c677b3ba5ab318a19333";
const BUILDING_3_SOURCE = "w34313540";
const BUILDING_3_WALL = "building:w34313540:wall";
const BUILDING_3_ROOF = "building:w34313540:roof";
const BUILDING_3_MASSING_PATH = "game/scripts/world/massing/building_3_600_california_massing.gd";
const BUILDING_3_CONFIG_PATH = "game/resources/facades/building_3_hero_massing.json";
const BUILDING_3_AUTHORING_PROVENANCE_PATH = "discovery/facades/building_3_hero_massing_capture_source_snapshot_2026-09-04.json";
const BUILDING_3_AUTHORING_PROVENANCE_SHA256 = "149d9211c75e86c769243298d649b79b682c1b4873af5d86d30a5d04aa1a26bd";
const BUILDING_3_FACADE_ASSET_PATHS = Object.freeze([
  "game/resources/facades/building_3_600_california_ene_layout.json",
  "game/resources/materials/world/building_3/building_3_shadow_recess.tres",
  "game/resources/materials/world/building_3/building_3_teal_door.tres",
  "game/resources/materials/world/building_3/building_3_white_primary.tres",
  "game/scenes/world/facades/building_3/building_3_600_california_facade.tscn",
  "game/scenes/world/facades/building_3/building_3_ene_modules.tscn",
  "game/scripts/world/facades/building_3_600_california_facade.gd",
]);
const WORLD_CHUNK_BUILDER_PATH = "game/scripts/world/world_chunk_builder.gd";
const D2_1441_REVIEWED_WORLD_BUILDER_DEPENDENCY_PATHS = Object.freeze([
  "game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
  "game/resources/textures/world/polyhaven/bitumen/bitumen_nor_gl_1k.jpg",
  "game/resources/textures/world/polyhaven/bitumen/bitumen_rough_1k.jpg",
  "game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg",
  "game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_nor_gl_1k.jpg",
  "game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_rough_1k.jpg",
  "game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_diff_1k.jpg",
  "game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_nor_gl_1k.jpg",
  "game/resources/textures/world/polyhaven/concrete_floor_03/concrete_floor_03_rough_1k.jpg",
  "game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_diff_1k.jpg",
  "game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_nor_gl_1k.jpg",
  "game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_rough_1k.jpg",
  "game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_diff_1k.jpg",
  "game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_nor_gl_1k.jpg",
  "game/resources/textures/world/polyhaven/plaster_grey_04/plaster_grey_04_rough_1k.jpg",
  "game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg",
  "game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_nor_gl_1k.jpg",
  "game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_rough_1k.jpg",
  "game/scenes/world/facades/isle_house/isle_house_high_facade.tscn",
  "game/scripts/world/facades/accepted_material_run_trials.gd",
  BUILDING_1_HERO_ADAPTER_PATH,
  "game/scripts/world/facades/d1_b201_live_attachment.gd",
  "game/scripts/world/facades/d1_b225_live_attachment.gd",
  "game/scripts/world/facades/d2_1441_chinook_live_replacement.gd",
  ISLE_HOUSE_LIVE_ADAPTER_PATH,
  "game/scripts/world/facades/navy_chapel_187_live_replacement.gd",
  "game/scripts/world/facades/w291196370_live_modules.gd",
  "game/scripts/world/facades/w34313515_live_modules.gd",
  "game/scripts/world/facades/w34313520_live_modules.gd",
  "game/scripts/world/facades/w34313525_live_modules.gd",
  "game/scripts/world/facades/w34313564_live_modules.gd",
  BUILDING_3_MASSING_PATH,
  "game/scripts/world/massing/hawkins_77_bruton_massing.gd",
]);
const FACADE_RUNTIME_LOADER_PATH = "game/scripts/world/facades/facade_runtime_registry_loader.gd";
const NAVY_CHAPEL_SOURCE = "w291189336";
const NAVY_CHAPEL_WALL = "building:w291189336:wall";
const NAVY_CHAPEL_ROOF = "building:w291189336:roof";
const NAVY_CHAPEL_LIVE_ADAPTER_PATH = "game/scripts/world/facades/navy_chapel_187_live_replacement.gd";
const NAVY_CHAPEL_PROTOTYPE_PATH = "game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd";
const NAVY_CHAPEL_CONFIG_PATH = "game/resources/facades/navy_chapel_187_standalone_hero_prototype.json";
const NAVY_CHAPEL_LIVE_REVIEW_RECEIPT_SHA256 = "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9";
const NAVY_CHAPEL_GEOMETRY_SIGNATURE = "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46";
const NAVY_CHAPEL_OWNERSHIP_SIGNATURE = "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7";
const NAVY_CHAPEL_RUNTIME_ASSET_PATHS = Object.freeze([
  "game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
  "game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres",
  "game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres",
  "game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres",
  "game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres",
  "game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres",
  NAVY_CHAPEL_PROTOTYPE_PATH,
]);
const D1_B201_SOURCE = "w34313545";
const D1_B201_WALL = "building:w34313545:wall";
const D1_B201_ROOF = "building:w34313545:roof";
const D1_B201_CONFIG_PATH = "game/resources/facades/d1_current/d1_b201_live_attachment.json";
const D1_B201_LIVE_ADAPTER_PATH = "game/scripts/world/facades/d1_b201_live_attachment.gd";
const D1_B201_CONFIG_SHA256 = "0f3bf052688ec813b5fa58b077d74c963949574623fe4cf67c12c347e7257229";
const D1_B201_LIVE_ADAPTER_SHA256 = "499f6d2657b593ee5b0801cf1205a2925a993f3b1836922d3656a6d00c51cc19";
const D1_B201_REVIEWED_WORLD_BUILDER_SHA256 = "71e391e4fa58afc83e4bcb99a9f8195e398fdf4064bb09a401fb079e9f30491c";
const D1_B201_LIVE_REVIEW_RECEIPT_SHA256 = "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772";
const D1_B201_EVIDENCE_MANIFEST_SHA256 = "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3";
const D1_B201_DECORATIVE_GEOMETRY_SIGNATURE = "705c5345509f77cd91359f66173fff0e1e132d41ebb9acef3f51ff2c467abb3a";
const PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_b201_integration_live_parity";
const PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_b225_integration_live_parity";
const CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "current_integration_topology";
const D1_B201_RUNTIME_ASSET_PATHS = Object.freeze([
  "game/resources/materials/world/d1_current/b201_green_hierarchy.tres",
  "game/resources/materials/world/d1_current/b201_muted_rust_post.tres",
  "game/resources/materials/world/d1_current/b201_service_leaf.tres",
  "game/resources/materials/world/d1_current/b201_warm_wall.tres",
  "game/resources/materials/world/d1_current/shared_dark_glass.tres",
  "game/resources/materials/world/d1_current/shared_pale_frame.tres",
]);
const D1_B225_SOURCE = "w95934119";
const D1_B225_WALL = "building:w95934119:wall";
const D1_B225_ROOF = "building:w95934119:roof";
const D1_B225_CONFIG_PATH = "game/resources/facades/d1_current/d1_b225_live_attachment.json";
const D1_B225_LIVE_ADAPTER_PATH = "game/scripts/world/facades/d1_b225_live_attachment.gd";
const D1_B225_CONFIG_SHA256 = "80b42c33fce84361aa7512f64305f5bff273e8fed95640ca4f9c19d49d55621d";
const D1_B225_LIVE_ADAPTER_SHA256 = "4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9";
const D1_B225_REVIEWED_WORLD_BUILDER_SHA256 = "de4a2924d275a51dfd08aae1f0ef21daac33395b1fcfe98e260fbc90737dd725";
const D1_B225_LIVE_REVIEW_RECEIPT_SHA256 = "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95";
const D1_B225_EVIDENCE_MANIFEST_SHA256 = "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc";
const D1_B225_EVIDENCE_TREE_SHA256 = "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7";
const D1_B225_DECORATIVE_GEOMETRY_SIGNATURE = "02bd8542dea7aa13041728a5244ec962fa121972db17ecf55fad03b3139fe418";
const D1_B225_RUNTIME_ASSET_PATHS = Object.freeze([
  "game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres",
  "game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png",
  "game/resources/materials/world/d1_current/shared_dark_glass.tres",
  "game/resources/materials/world/d1_current/shared_pale_frame.tres",
]);
const PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_d2_1441_integration_live_parity";
const D2_1441_SOURCE = "w95934105";
const D2_1441_WALL = "building:w95934105:wall";
const D2_1441_ROOF = "building:w95934105:roof";
const D2_1441_CONFIG_PATH = "game/resources/facades/d2_1441_chinook_live_replacement.json";
const D2_1441_LIVE_ADAPTER_PATH = "game/scripts/world/facades/d2_1441_chinook_live_replacement.gd";
const D2_1441_PROTOTYPE_PATH = "game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd";
const D2_1441_PROTOTYPE_CONFIG_PATH = "game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json";
const D2_1441_SITE_KIT_PATH = "game/scripts/world/facades/site_12_housing_kit.gd";
const D2_1441_CONFIG_SHA256 = "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111";
const D2_1441_LIVE_ADAPTER_SHA256 = "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1";
const D2_1441_REVIEWED_WORLD_BUILDER_SHA256 = "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a";
const D2_1441_GEOMETRY_SIGNATURE = "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195";
const D2_1441_OWNERSHIP_SIGNATURE = "fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d";
const D2_1441_EVIDENCE_ROOT = "evidence/first-playable/d2-1441-production-v8-staging-2026-09-05-009";
const D2_1441_EVIDENCE_MANIFEST_PATH = `${D2_1441_EVIDENCE_ROOT}/capture-manifest.json`;
const D2_1441_MOTION_TELEMETRY_MANIFEST_PATH = `${D2_1441_EVIDENCE_ROOT}/motion-telemetry.json`;
const D2_1441_VISUAL_MOTION_MANIFEST_PATH = `${D2_1441_EVIDENCE_ROOT}/visual-motion.json`;
const D2_1441_PACKAGE_VERIFICATION_RECEIPT_PATH = `${D2_1441_EVIDENCE_ROOT}/package-verification-receipt.json`;
const D2_1441_MECHANICAL_REVIEW_PATH = "evidence/reviews/d2-1441-production-v8-staging-2026-09-05-009-INDEPENDENT_CONTRACT_AUDIT.md";
const D2_1441_VISUAL_REVIEW_PATH = "evidence/reviews/d2-1441-production-v8-staging-2026-09-05-009-INDEPENDENT_VISUAL_REVIEW.md";
const D2_1441_EVIDENCE_MANIFEST_SHA256 = "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885";
const D2_1441_MOTION_TELEMETRY_MANIFEST_SHA256 = "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd";
const D2_1441_VISUAL_MOTION_MANIFEST_SHA256 = "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad";
const D2_1441_EVIDENCE_TREE_SHA256 = "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43";
const D2_1441_PACKAGE_VERIFICATION_RECEIPT_SHA256 = "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061";
const D2_1441_MECHANICAL_REVIEW_RECEIPT_SHA256 = "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884";
const D2_1441_VISUAL_REVIEW_RECEIPT_SHA256 = "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144";
const D2_1441_REVIEW_ID = "d2-1441-production-v8-staging-2026-09-05-009";
const D2_1441_MAPPED_RUNS = Object.freeze([10, 12, 13, 15]);
const D2_1441_PROTECTED_RUNS = Object.freeze([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14]);
const D2_1441_RUNTIME_ASSET_PATHS = Object.freeze([
  D2_1441_PROTOTYPE_CONFIG_PATH,
  "game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
  "game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
  "game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
  "game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
  "game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
  "game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
  "game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
  "game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
  D2_1441_PROTOTYPE_PATH,
  D2_1441_SITE_KIT_PATH,
]);

const D2_1439_SOURCE = "w95934144";
const D2_1439_WALL = "building:w95934144:wall";
const D2_1439_ROOF = "building:w95934144:roof";
const D2_1439_CONFIG_PATH = "game/resources/facades/d2_1439_chinook_quality_v2_live_replacement.json";
const D2_1439_LIVE_ADAPTER_PATH = "game/scripts/world/facades/d2_1439_chinook_quality_v2_live_replacement.gd";
const D2_1439_PROTOTYPE_PATH = "game/scripts/world/facades/d2_1439_chinook_quality_v2_prototype.gd";
const D2_1439_PROTOTYPE_CONFIG_PATH = "game/resources/facades/d2_1439_chinook_quality_v2_prototype.json";
const D2_1439_SITE_KIT_PATH = "game/scripts/world/facades/site_12_housing_kit.gd";
const D2_1439_CONFIG_SHA256 = "58ba0093d002a3acad06b76876b7333077bb5152827f4a59b0c9b6da132b68d9";
const D2_1439_LIVE_ADAPTER_SHA256 = "d5a4458be7a5c2fb6989f9d8a343d497d2f144eb19c445de6016888e7b3cce5e";
const D2_1439_REVIEWED_WORLD_BUILDER_SHA256 = "417e4f7269292ed0c5185e85f6b5d12759cdc516ca6be069898145aaab56ab50";
const D2_1439_GEOMETRY_SIGNATURE = "81a05d20b03e16253675a36692c9856cf4d53509e008aacbb69bbe4eea7683e5";
const D2_1439_OWNERSHIP_SIGNATURE = "82e1fdfae492aa1942bbbb5cfb65b51d4da4c980cf85a4231c2093aaf3edc27a";
const D2_1439_EVIDENCE_ROOT = "evidence/first-playable/d2-1439-quality-v2-promotion-candidate-2026-09-09-001";
const D2_1439_EVIDENCE_MANIFEST_PATH = `${D2_1439_EVIDENCE_ROOT}/capture-manifest.json`;
const D2_1439_MOTION_TELEMETRY_MANIFEST_PATH = `${D2_1439_EVIDENCE_ROOT}/motion-telemetry.json`;
const D2_1439_VISUAL_MOTION_MANIFEST_PATH = `${D2_1439_EVIDENCE_ROOT}/visual-motion.json`;
const D2_1439_PACKAGE_VERIFICATION_RECEIPT_PATH = `${D2_1439_EVIDENCE_ROOT}/package-verification-receipt.json`;
const D2_1439_MECHANICAL_REVIEW_PATH = "evidence/first-playable/d2-1439-quality-v2-promotion-candidate-2026-09-09-001/mechanical-review.json";
const D2_1439_VISUAL_REVIEW_PATH = "evidence/reviews/d2-1439-quality-v2-promotion-candidate-2026-09-09-001-INDEPENDENT_PACKET_REVIEW.md";
const D2_1439_EVIDENCE_MANIFEST_SHA256 = "32454a02699ebce9e29e8313e70fe93894c52bd3a4ddb46c08ffeaee54891a6a";
const D2_1439_MOTION_TELEMETRY_MANIFEST_SHA256 = "af5f7501b08cd36629123ad14b169da764d0c375f53a6167fee80843d7a1c863";
const D2_1439_VISUAL_MOTION_MANIFEST_SHA256 = "262183b9dd5424df20527ad097bc2a07921c1f24c2ce5d359a6d7aa096052683";
const D2_1439_EVIDENCE_TREE_SHA256 = "bd5c009e49545f5ef84b8f0c2032c1f59dd2054d4afe0aa1f9145f74a03e2426";
const D2_1439_PACKAGE_VERIFICATION_RECEIPT_SHA256 = "56b93dc9a3e4300d6c64261618add170488002e8c305d34889d30fd55ad41af1";
const D2_1439_MECHANICAL_REVIEW_RECEIPT_SHA256 = "f55d7a4df3fea5a1cf936d75ff0b8690b9c94f005992e5cc26da793304402119";
const D2_1439_VISUAL_REVIEW_RECEIPT_SHA256 = "cf1723b330fbd208fe92e27f5593c5f203b8f8cb99ff383ec8b389005fcc745c";
const D2_1439_REVIEW_ID = "d2-1439-quality-v2-promotion-candidate-2026-09-09-001";
const D2_1439_MAPPED_RUNS = Object.freeze([11, 12, 16, 17, 18, 19, 22, 23]);
const D2_1439_PROTECTED_RUNS = Object.freeze([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 20, 21]);
const D2_1439_RUNTIME_ASSET_PATHS = Object.freeze([
  D2_1439_PROTOTYPE_CONFIG_PATH,
  "game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
  "game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
  "game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
  "game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
  "game/resources/materials/world/site_12_housing/d2_1439_quality_v2_recess_backing.tres",
  "game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
  "game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
  "game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
  D2_1439_PROTOTYPE_PATH,
  D2_1439_SITE_KIT_PATH,
]);

const D2_1444_SOURCE = "w95934117";
const D2_1444_WALL = "building:w95934117:wall";
const D2_1444_ROOF = "building:w95934117:roof";
const D2_1444_CONFIG_PATH = "game/resources/facades/d2_1444_croaker_quality_v2_live_replacement.json";
const D2_1444_LIVE_ADAPTER_PATH = "game/scripts/world/facades/d2_1444_croaker_quality_v2_live_replacement.gd";
const D2_1444_PROTOTYPE_PATH = "game/scripts/world/facades/d2_1444_croaker_quality_v2_prototype.gd";
const D2_1444_PROTOTYPE_CONFIG_PATH = "game/resources/facades/d2_1444_croaker_quality_v2_prototype.json";
const D2_1444_SITE_KIT_PATH = "game/scripts/world/facades/site_12_housing_kit.gd";
const D2_1444_CONFIG_SHA256 = "472f82f5a3d98b0778aca758ae8277f8b8ba9b4a39875ff54f67781280965135";
const D2_1444_LIVE_ADAPTER_SHA256 = "178cc9df2c7add966a95427099b3a9900fde459e5bfc4825211e06c119cc2e32";
const D2_1444_REVIEWED_WORLD_BUILDER_SHA256 = "cbc3f6d90e5200ea81f1daaccd10442a98b0531c5c6e5358fe825bebef89fcbb";
const D2_1444_GEOMETRY_SIGNATURE = "1dba8f84003a0818c2ddb91504f41c3437a63fe0856ade70d1c194ca1be8d141";
const D2_1444_OWNERSHIP_SIGNATURE = "979910c4d53486b86db04cdf04528789f668a01c41dc27114e481c843b91b92d";
const D2_1444_EVIDENCE_ROOT = "evidence/first-playable/d2-1444-quality-v2-promotion-candidate-2026-09-09-001";
const D2_1444_EVIDENCE_MANIFEST_PATH = `${D2_1444_EVIDENCE_ROOT}/capture-manifest.json`;
const D2_1444_MOTION_TELEMETRY_MANIFEST_PATH = `${D2_1444_EVIDENCE_ROOT}/motion-telemetry.json`;
const D2_1444_VISUAL_MOTION_MANIFEST_PATH = `${D2_1444_EVIDENCE_ROOT}/visual-motion.json`;
const D2_1444_PACKAGE_VERIFICATION_RECEIPT_PATH = `${D2_1444_EVIDENCE_ROOT}/package-verification-receipt.json`;
const D2_1444_MECHANICAL_REVIEW_PATH = "evidence/first-playable/d2-1444-quality-v2-promotion-candidate-2026-09-09-001/mechanical-review.json";
const D2_1444_VISUAL_REVIEW_PATH = "evidence/reviews/d2-1444-quality-v2-promotion-candidate-2026-09-09-001-INDEPENDENT_PACKET_REVIEW.md";
const D2_1444_EVIDENCE_MANIFEST_SHA256 = "9f1101abb3e4d6ac54f27a8a6db7d72ccd098721d0f59e8a6f72a6aa4c1293ef";
const D2_1444_MOTION_TELEMETRY_MANIFEST_SHA256 = "b569a5dc8b72c99c873a85c4fbc49b701ba72647a0299a4f8e7b0ff06b7309bc";
const D2_1444_VISUAL_MOTION_MANIFEST_SHA256 = "327d9980de0798d7412ea691bd656f278a5e04da383c24fdb1cb272305b29e38";
const D2_1444_EVIDENCE_TREE_SHA256 = "6872fe9f286370de3ab11ce27124583689a7fa0c4992bb4de4f2b9e8e1073003";
const D2_1444_PACKAGE_VERIFICATION_RECEIPT_SHA256 = "b738e35d58ef6e75d0c4d98ae32d6157532703984fd48730281629211fe355a4";
const D2_1444_MECHANICAL_REVIEW_RECEIPT_SHA256 = "7e62e914074646e438bc7c88a1f15fbc71eb40bfa00a0b04acf20e22e319c205";
const D2_1444_VISUAL_REVIEW_RECEIPT_SHA256 = "89c301ccdf5d02b71c5f4d79eacfee55521440edfbe2c6d780cd7c1d059d72c7";
const D2_1444_REVIEW_ID = "d2-1444-quality-v2-promotion-candidate-2026-09-09-001";
const D2_1444_MAPPED_RUNS = Object.freeze([8, 9, 11, 12, 15, 16, 17]);
const D2_1444_PROTECTED_RUNS = Object.freeze([0, 1, 2, 3, 4, 5, 6, 7, 10, 13, 14, 18, 19, 20, 21]);
const D2_1444_RUNTIME_ASSET_PATHS = Object.freeze([
  D2_1444_PROTOTYPE_CONFIG_PATH,
  "game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
  "game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
  "game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
  "game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
  "game/resources/materials/world/site_12_housing/d2_1444_quality_v2_recess_backing.tres",
  "game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres",
  "game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
  "game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
  D2_1444_PROTOTYPE_PATH,
  D2_1444_SITE_KIT_PATH,
]);

const PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_d2_1444_integration_live_parity";
const PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE = "pre_d2_1439_integration_live_parity";

const ACCEPTED_REFERENCE_UNIT_IDS = Object.freeze([
  "physical-building:r16681702",
  "physical-building:w1222720021",
  "physical-building:w1249412093",
  "physical-building:w1249412094",
  "physical-building:w291189336",
  "physical-building:w34313540",
  "physical-building:w34313545",
  "physical-building:w95934105",
  "physical-building:w95934117",
  "physical-building:w95934119",
  "physical-building:w95934144",
  "physical-building:w95934123",
  "physical-building:w96215646",
  "physical-building:w95934125",
  "physical-building:w764313741",
]);

const D5_BATCH_ACCEPTED = Object.freeze([
  {
    "number": "1308",
    "source": "w95934123",
    "wall": "building:w95934123:wall",
    "roof": "building:w95934123:roof",
    "unit_id": "physical-building:w95934123",
    "adapter_id": "active-adapter:d5-1308-live:building:w95934123:wall",
    "mode": "active_d5_1308_paired_replacement",
    "files": {
      "adapter": "game/scripts/world/facades/d5_1308_gateview_live_replacement.gd",
      "config": "game/resources/facades/d5_1308_gateview_live_replacement.json",
      "factory": "game/scripts/world/facades/d5_1308_gateview_live_factory.gd",
      "factory_config": "game/resources/facades/d5_1308_gateview_live_factory.json",
      "shader": "game/resources/facades/d5_1308_siding_marks.gdshader",
      "site_kit": "game/scripts/world/facades/site_12_housing_kit.gd",
      "lawn_shader": "game/resources/facades/d5_1308_lawn_tone.gdshader"
    },
    "hashes": {
      "adapter": "3faca37243c2ee51ff1d2834b3d581d4b7d4552a45179224371a2570b7f08ad5",
      "config": "c35951faebaa921d41bf0230bf511b3a3fde9b9b1f533272030a5dfb8d8dfe8a",
      "factory": "6950aab112f73fdf78c1cad2f3deca72ac7e46b2a07faffe04f82987a1e07498",
      "factory_config": "5fb9d42425df7d6f8b62ffdc3053e88ee559dc0efd0e7880b5e841ed0bf1ac8a",
      "shader": "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e",
      "site_kit": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
      "lawn_shader": "d60b1db292234046d2e8fd1a451e0f3f52a69b12afe401e871bedef6067ca7af"
    },
    "config": {
      "schema_version": "ti.d5-1308-gateview-live-replacement/1",
      "adapter_id": "active-adapter:d5-1308-live:building:w95934123:wall",
      "source_key": "w95934123",
      "source_geometry_sha256": "6028c89be31ebfd095777b86f6d5d4a9094002b7b5fd73efb2fc940f9a9f3917",
      "chunk_id": "x_-2__z_-1",
      "chunk_sha256": "6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2",
      "canonical_records": {
        "area:r17241151:x_-2__z_-1": "0c1ca3e7d64c4fe9c5d561a00832651fa634b7a0c3bfae9f8434fa9526c58e53",
        "building:w95934123:roof": "34d0a95387fc6f17a889aac602ce5e630a67b4d0d9f8b5fb6264291d674b7b00",
        "building:w95934123:wall": "5bf75fcc75fdbc83d45a97a6a4168a439e8c31bcbc473105147f831a09458abd",
        "land:w26767313:x_-2__z_-1": "5508f75d3cc82559353123a3af167a0bb5b375eea73b84537d38a82b595579f7"
      },
      "factory_config_sha256": "5fb9d42425df7d6f8b62ffdc3053e88ee559dc0efd0e7880b5e841ed0bf1ac8a",
      "reviewed_factory_source_sha256": "059c891e8ed3ee8ad25af7d30f9cd7ba0d32724e242ec4730e18389911c15619",
      "reviewed_factory_config_sha256": "dad5478b497336c5f0e0cae98852ac0e17556b5ba41cc3e0dc4b54c61a9a402d",
      "accepted_source_world_mechanics_receipt_sha256": "3cce21ec2d08bdcc18aa0d91993d94edb2c7e68115067c6e69418df7af451a1d",
      "accepted_source_world_visual_receipt_sha256": "2d9c610aec2be26857a9d3102ec7668a8241de6341be7dbd20c3084d56289927",
      "mapped_runs": [
        0,
        1,
        2,
        3,
        5,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        17,
        18,
        19,
        20,
        21,
        27,
        32
      ],
      "protected_runs": [
        4,
        6,
        15,
        16,
        22,
        23,
        24,
        25,
        26,
        28,
        29,
        30,
        31,
        33
      ],
      "pair_contract": {
        "meshes": 17,
        "surfaces": 17,
        "triangles": 4871,
        "bodies": 2,
        "shapes": 6,
        "collision_triangles": 2598,
        "wall_collision_triangles": 1196,
        "eligible_wall_triangles": 68,
        "noneligible_canopy_post_triangles": 240,
        "noneligible_pad_triangles": 96,
        "roof_triangles": 1402,
        "factory_calls": 1,
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "stack_allowed": false,
        "wall_shapes": 4,
        "roof_shapes": 2,
        "wall_triangles": 3469,
        "noneligible_lower_triangles": 792
      },
      "truth_boundary": {
        "historical_source_world_metric": "10/213",
        "candidate_authority_metric": "11/213",
        "candidate_authority_schema": "ti.facade-runtime-registry/11",
        "candidate_credit": 0,
        "runtime_attachment": true,
        "production_attachment_review": "pending",
        "grade_pad_source_world_traversal": "accepted_scoped; original strict exit contact FAIL preserved; outgoing direct land contact ownership unproven",
        "as_built_claim": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "recognition_accepted": false
      },
      "package_boundary": {
        "source_photography": false,
        "discovery_dependency": false,
        "activation_flag": false,
        "missing_pair_loaded_from_disk": false
      },
      "fidelity_revision_001": {
        "scope": "revision004: straight planar public corner tapers restore prior0.9m roof omissions within existing5.1m bands; gray internal end closures;003 canopy/lower/lawn/apron geometry and current13 unchanged; no inward connectors",
        "render_counts": {
          "DeepRepeatedGableCanopyRoofs": 54,
          "PaleSidedCanopyGableFronts": 18,
          "ExactSourceNeutralRoof": 22,
          "GroundFlushCanopySupportSlabs": 96,
          "ObservedWSWSSEHorizontalSidingFields": 40,
          "ProtectedExactNeutralWallRuns": 28,
          "RealCanopyFrontSupports": 144,
          "RepeatedOpaqueUpperSliders": 264,
          "RestrainedRealWindowAndCanopyTrim": 1872,
          "ClosedLowerDoors": 72,
          "ClosedLowerWindows": 72,
          "LowerOpeningFramesAndHandles": 648,
          "PublicPitchedRoofSlopes": 678,
          "PublicPaleRoofFasciaAndSoffit": 702,
          "ConnectedConcreteAprons": 39,
          "LocalFrontageLawn": 98,
          "ReadableCanopyRoofTops": 24
        },
        "old_collision426_exact_subset": true,
        "new_nonreceiver_closed_lower_triangles": 792,
        "new_roof_owned_triangles": 1380,
        "new_ground_visual_only_triangles": 137,
        "new_ground_collider": false,
        "protected_and_original22roof_exact": true
      }
    },
    "behavior": {
      "schema_version": "ti.d5-1308-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "7c01ff32b1da4276ec330aee0d034dce4f0cbe8caa510f96d99504084cb314b5",
        "motion_telemetry_manifest_sha256": "f139576c7b45eb76774315745504992f6bd726cd698faab6b88e79f491197960",
        "visual_motion_manifest_sha256": "f0d21bb4dc14d8a12aba1fc37614e3cced7ff331521dda06a802bfc6fbd69dc9",
        "package_verification_receipt_sha256": "c892d30b9c06f280077712c2bbad710eefac67f9fa1dd4b1f92c8f07c0b329dc",
        "evidence_tree_sha256": "e17f311ea69445d8da9b4029e9d4d93fba19ea2cd2901efa2e2ec1d7dd90556a",
        "mechanical_review_receipt_sha256": "9c094ed7a52506404a6763298504b71706b75ade1f44e4cfe2ad3fb6ea81380f",
        "review_receipt_sha256": "87a2af8c5ab11082337265f53ca5fcd3aa9f0dbfdd22f97e7a8968653ad71a06",
        "accepted_physical_unit_id": "physical-building:w95934123",
        "capture_time_recognition_metric": "13/213",
        "numerator_effect": 0,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w95934123",
        "wall_object_key": "building:w95934123:wall",
        "roof_object_key": "building:w95934123:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": true,
        "mapped_public_run_indices": [
          0,
          1,
          2,
          3,
          5,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          17,
          18,
          19,
          20,
          21,
          27,
          32
        ],
        "protected_run_indices": [
          4,
          6,
          15,
          16,
          22,
          23,
          24,
          25,
          26,
          28,
          29,
          30,
          31,
          33
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1
      },
      "geometry_contract": {
        "source_geometry_sha256": "6028c89be31ebfd095777b86f6d5d4a9094002b7b5fd73efb2fc940f9a9f3917",
        "canonical_wall_record_sha256": "5bf75fcc75fdbc83d45a97a6a4168a439e8c31bcbc473105147f831a09458abd",
        "canonical_roof_record_sha256": "34d0a95387fc6f17a889aac602ce5e630a67b4d0d9f8b5fb6264291d674b7b00",
        "canonical_terrain_records": {
          "area:r17241151:x_-2__z_-1": "0c1ca3e7d64c4fe9c5d561a00832651fa634b7a0c3bfae9f8434fa9526c58e53",
          "land:w26767313:x_-2__z_-1": "5508f75d3cc82559353123a3af167a0bb5b375eea73b84537d38a82b595579f7"
        },
        "horizontal_source_footprint_preserved": true,
        "visual_mesh_instances": 17,
        "visual_surfaces": 17,
        "visual_triangles": 4871,
        "world_records": 735,
        "world_mesh_instances": 1006,
        "world_surfaces": 1021,
        "world_triangles": 79913,
        "world_static_bodies": 466,
        "world_shapes": 474,
        "world_topology_scope": "same_batch_combined_topology_reference",
        "capture_isolated_world_mesh_instances": 1002,
        "capture_isolated_world_surfaces": 1017,
        "capture_isolated_world_triangles": 78685,
        "capture_isolated_world_shapes": 474
      },
      "ownership_contract": {
        "structural_owner_count": 2,
        "shape_count": 6,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "eligible_exterior",
          "noneligible_canopy_posts",
          "noneligible_grade_pads",
          "noneligible_closed_lower"
        ],
        "eligible_exterior_collision_triangles": 68,
        "noneligible_canopy_post_collision_triangles": 240,
        "noneligible_ground_collision_triangles": 96,
        "wall_collision_triangles": 1196,
        "roof_collision_triangles": 1402,
        "roof_is_wall_spray_receiver": false,
        "roof_world_solid_landing": true,
        "eligible_render_layer": 2,
        "noneligible_render_layer": 1,
        "terrain_geometry_and_ownership_unchanged": true,
        "noneligible_closed_lower_collision_triangles": 792,
        "roof_shape_order": [
          "exact_source_roof",
          "added_public_roof"
        ],
        "roof_shape_collision_triangles": [
          22,
          1380
        ]
      },
      "truth_boundary": {
        "as_built_fidelity_claimed": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "capture_time_recognition_credit": false,
        "capture_time_candidate_promoted": false,
        "reference_pixels_packaged": false,
        "receiver_complete_inferred_from_art": false,
        "game_distinctive_claimed": false,
        "unobserved_sides_protected": true,
        "unsurveyed_dimensions_and_counts_are_production_inference": true,
        "direct_continuous_outgoing_land_contact_ownership_claimed": false
      }
    },
    "acceptance": {
      "evidence_manifest_sha256": "7c01ff32b1da4276ec330aee0d034dce4f0cbe8caa510f96d99504084cb314b5",
      "motion_telemetry_manifest_sha256": "f139576c7b45eb76774315745504992f6bd726cd698faab6b88e79f491197960",
      "visual_motion_manifest_sha256": "f0d21bb4dc14d8a12aba1fc37614e3cced7ff331521dda06a802bfc6fbd69dc9",
      "package_verification_receipt_sha256": "c892d30b9c06f280077712c2bbad710eefac67f9fa1dd4b1f92c8f07c0b329dc",
      "evidence_tree_sha256": "e17f311ea69445d8da9b4029e9d4d93fba19ea2cd2901efa2e2ec1d7dd90556a",
      "mechanical_review_receipt_sha256": "9c094ed7a52506404a6763298504b71706b75ade1f44e4cfe2ad3fb6ea81380f",
      "review_receipt_sha256": "87a2af8c5ab11082337265f53ca5fcd3aa9f0dbfdd22f97e7a8968653ad71a06",
      "capture_time_recognition_metric": "13/213",
      "numerator_effect": 0,
      "review_id": "d5-1308-fidelity-quality-candidate-2026-09-10-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "receipt": {
      "evidence_manifest_sha256": "7c01ff32b1da4276ec330aee0d034dce4f0cbe8caa510f96d99504084cb314b5",
      "motion_telemetry_manifest_sha256": "f139576c7b45eb76774315745504992f6bd726cd698faab6b88e79f491197960",
      "visual_motion_manifest_sha256": "f0d21bb4dc14d8a12aba1fc37614e3cced7ff331521dda06a802bfc6fbd69dc9",
      "package_verification_receipt_sha256": "c892d30b9c06f280077712c2bbad710eefac67f9fa1dd4b1f92c8f07c0b329dc",
      "evidence_tree_sha256": "e17f311ea69445d8da9b4029e9d4d93fba19ea2cd2901efa2e2ec1d7dd90556a",
      "mechanical_review_receipt_sha256": "9c094ed7a52506404a6763298504b71706b75ade1f44e4cfe2ad3fb6ea81380f",
      "review_receipt_sha256": "87a2af8c5ab11082337265f53ca5fcd3aa9f0dbfdd22f97e7a8968653ad71a06",
      "capture_time_recognition_metric": "13/213",
      "numerator_effect": 0,
      "unit_id": "physical-building:w95934123",
      "evidence_manifest_path": "evidence/first-playable/d5-1308-fidelity-quality-candidate-2026-09-10-001/capture-manifest.json",
      "motion_telemetry_manifest_path": "evidence/first-playable/d5-1308-fidelity-quality-candidate-2026-09-10-001/motion-telemetry.json",
      "visual_motion_manifest_path": "evidence/first-playable/d5-1308-fidelity-quality-candidate-2026-09-10-001/visual-motion.json",
      "package_verification_receipt_path": "evidence/first-playable/d5-1308-fidelity-quality-candidate-2026-09-10-001/package-verification-receipt.json",
      "evidence_tree_path": "evidence/first-playable/d5-1308-fidelity-quality-candidate-2026-09-10-001/evidence-tree.json",
      "mechanical_review_receipt_path": "evidence/first-playable/d5-1308-fidelity-quality-candidate-2026-09-10-001/mechanical-review.json",
      "review_path": "evidence/first-playable/d5-1308-fidelity-quality-candidate-2026-09-10-001/unit-visual-attestation.json"
    },
    "tree_document_sha256": "6f14bbea0a9b483b1ff6fb43c907253f1e353e49f4a8cc31b73a9dac20671bfe",
    "image_count": 17
  },
  {
    "number": "1394",
    "source": "w96215646",
    "wall": "building:w96215646:wall",
    "roof": "building:w96215646:roof",
    "unit_id": "physical-building:w96215646",
    "adapter_id": "active-adapter:d5-1394-live:building:w96215646:wall",
    "mode": "active_d5_1394_paired_replacement",
    "files": {
      "adapter": "game/scripts/world/facades/d5_1394_gateview_live_replacement.gd",
      "config": "game/resources/facades/d5_1394_gateview_live_replacement.json",
      "factory": "game/scripts/world/facades/d5_1394_gateview_live_factory.gd",
      "factory_config": "game/resources/facades/d5_1394_gateview_live_factory.json",
      "shader": "game/resources/facades/d5_1394_siding_marks.gdshader",
      "site_kit": "game/scripts/world/facades/site_12_housing_kit.gd",
      "lawn_shader": "game/resources/facades/d5_1394_lawn_tone.gdshader"
    },
    "hashes": {
      "adapter": "42e0233cdbe1be7bdcbb63603c1bb2cae4c247dde87a51f9518cc1afafc82076",
      "config": "3d74e15f0a438dd4a45f2c778c415879888ef1b7a3cef75ebe7a9682db4de203",
      "factory": "25284afdd779f6b491da47218fc6fdd169dad3bb3c56da70d76680cc91781fcb",
      "factory_config": "2f383cef8b7f141c2a4d30a5f40db45ac166fba4c52539a84a11f7e9cb3b8c86",
      "shader": "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e",
      "site_kit": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
      "lawn_shader": "d60b1db292234046d2e8fd1a451e0f3f52a69b12afe401e871bedef6067ca7af"
    },
    "config": {
      "schema_version": "ti.d5-1394-gateview-live-replacement/1",
      "adapter_id": "active-adapter:d5-1394-live:building:w96215646:wall",
      "source_key": "w96215646",
      "source_geometry_sha256": "b0e6c7426ac41c995f96a647ff5102b4d85963d2b7a45f21ad1b81455e451220",
      "chunk_id": "x_-2__z_-3",
      "chunk_sha256": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
      "canonical_records": {
        "area:r17241151:x_-2__z_-3": "462c4532716ddaa63c66d0c11300771ee7eb1089c27565037fb2e148b85c5d7c",
        "building:w96215646:roof": "299f27cd69cc90668bdd31cb076d083ee1bf98e28b0031cdbe4e38bfd0c2cc51",
        "building:w96215646:wall": "222fc29f2d1526d983f4653dc8ae157aa98575dbbfb16c89898827a26dc26019",
        "land:w26767313:x_-2__z_-3": "17c60f0f623bf919bd05c0ebc4ae93c06cce0c33a5603725175f3c4754572c02"
      },
      "factory_config_sha256": "2f383cef8b7f141c2a4d30a5f40db45ac166fba4c52539a84a11f7e9cb3b8c86",
      "reviewed_factory_source_sha256": "aa112014ce0b56b153233934e8b3930b64bc576987bd882e22e26c42b80a7abd",
      "reviewed_factory_config_sha256": "f20133c69e87f8fd573e215ec5b4c6adf3e308f51ec5c6fccbcee6550f251f30",
      "accepted_source_world_mechanics_receipt_sha256": "0a049b0af97211a50e9365f6ec3acdc3c7a33060b4f3c8e9c3bf2d1d3a827d05",
      "accepted_source_world_visual_receipt_sha256": "6be84c50a594ed25050419af477d9e1e98f577bcecf117a02b27909593b7fb0a",
      "mapped_runs": [
        1,
        2,
        3,
        4,
        15,
        16,
        17,
        18,
        20,
        21,
        22,
        23
      ],
      "protected_runs": [
        0,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        19
      ],
      "address_crosswalk": {
        "frozen_house_number": "1230",
        "current_house_number": "1394",
        "street_suffix": "Court/Avenue discrepancy retained; frozen source has no street tag"
      },
      "pair_contract": {
        "meshes": 16,
        "surfaces": 16,
        "triangles": 3368,
        "bodies": 2,
        "shapes": 4,
        "collision_triangles": 2284,
        "wall_collision_triangles": 2268,
        "eligible_wall_triangles": 48,
        "noneligible_canopy_post_triangles": 204,
        "noneligible_closed_module_triangles": 2016,
        "roof_triangles": 16,
        "factory_calls": 1,
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "stack_allowed": false
      },
      "truth_boundary": {
        "historical_source_world_metric": "10/213",
        "candidate_authority_metric": "13/213",
        "candidate_authority_schema": "ti.facade-runtime-registry/13",
        "candidate_credit": 0,
        "runtime_attachment": true,
        "production_attachment_review": "prior live accepted; bounded fidelity revision source/contact/pixel review pending",
        "actual_grade_walking": "independent_scoped_PASS; original lowexit empty finalcontact FAIL preserved; no continuous support identity claim",
        "as_built_claim": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "recognition_accepted": false,
        "historical_live_candidate_authority_metric": "11/213",
        "historical_live_candidate_authority_schema": "ti.facade-runtime-registry/11"
      },
      "package_boundary": {
        "source_photography": false,
        "discovery_dependency": false,
        "activation_flag": false,
        "missing_pair_loaded_from_disk": false
      },
      "fidelity_refinement": {
        "scope": "Current13 correction study; historical accepted receipts above retained at their original source scope",
        "visual_only_ground_triangles": 76,
        "screen_triangles": 1224,
        "screens": 6,
        "member_boxes": 102,
        "source_ground_collision_unchanged": true,
        "new_acceptance_claim": false,
        "raw_polygon_fan_triangles": 82,
        "zero_area_fans_skipped_by_existing_guard": 6,
        "material_only_004": "Private LocalLawn hue/luminance mapping; geometry, UV arrays, collision and other materials remain003 exact"
      }
    },
    "behavior": {
      "schema_version": "ti.d5-1394-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "ec327adb9239a902f40fd7e2ede7afedcd19bf1869b392e9646544721eaec316",
        "motion_telemetry_manifest_sha256": "0ad7ff068f42b8230ba724d9143c9c563130de3c9d40c37837f1ed21f95ecc60",
        "visual_motion_manifest_sha256": "6a057c2b0236e90d11861499c299b723b35da37ee3590a0a154d0c3390f0b2cb",
        "package_verification_receipt_sha256": "9be91b038dc142ac84d3947ed68733c2346aa5756e4ccbb433bf0a173b8ca364",
        "evidence_tree_sha256": "464224831dfadcc4657fdb3575fc47501190ad41c44163a7dd05885284772689",
        "mechanical_review_receipt_sha256": "c2c4ee90347b458e44fda87d900a4a2031b2cf4883c16a0db1ceac0ffeec02cd",
        "review_receipt_sha256": "c7b5079a3a59847b80e201ef8107928381f9370dd74001f2675f0c68de82dbc8",
        "accepted_physical_unit_id": "physical-building:w96215646",
        "capture_time_recognition_metric": "13/213",
        "numerator_effect": 0,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w96215646",
        "wall_object_key": "building:w96215646:wall",
        "roof_object_key": "building:w96215646:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": true,
        "mapped_public_run_indices": [
          1,
          2,
          3,
          4,
          15,
          16,
          17,
          18,
          20,
          21,
          22,
          23
        ],
        "protected_run_indices": [
          0,
          5,
          6,
          7,
          8,
          9,
          10,
          11,
          12,
          13,
          14,
          19
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1
      },
      "geometry_contract": {
        "source_geometry_sha256": "b0e6c7426ac41c995f96a647ff5102b4d85963d2b7a45f21ad1b81455e451220",
        "canonical_wall_record_sha256": "222fc29f2d1526d983f4653dc8ae157aa98575dbbfb16c89898827a26dc26019",
        "canonical_roof_record_sha256": "299f27cd69cc90668bdd31cb076d083ee1bf98e28b0031cdbe4e38bfd0c2cc51",
        "canonical_terrain_records": {
          "area:r17241151:x_-2__z_-3": "462c4532716ddaa63c66d0c11300771ee7eb1089c27565037fb2e148b85c5d7c",
          "land:w26767313:x_-2__z_-3": "17c60f0f623bf919bd05c0ebc4ae93c06cce0c33a5603725175f3c4754572c02"
        },
        "horizontal_source_footprint_preserved": true,
        "visual_mesh_instances": 16,
        "visual_surfaces": 16,
        "visual_triangles": 3368,
        "world_records": 735,
        "world_mesh_instances": 1006,
        "world_surfaces": 1021,
        "world_triangles": 79913,
        "world_static_bodies": 466,
        "world_shapes": 474,
        "world_topology_scope": "pre_d5_1317_integration_quality_batch_topology",
        "capture_isolated_world_mesh_instances": 997,
        "capture_isolated_world_surfaces": 1012,
        "capture_isolated_world_triangles": 77604,
        "capture_isolated_world_shapes": 472
      },
      "ownership_contract": {
        "structural_owner_count": 2,
        "shape_count": 4,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "eligible_exterior",
          "noneligible_canopy_posts",
          "noneligible_closed_modules"
        ],
        "eligible_exterior_collision_triangles": 48,
        "noneligible_canopy_post_collision_triangles": 204,
        "noneligible_ground_collision_triangles": 2016,
        "wall_collision_triangles": 2268,
        "roof_collision_triangles": 16,
        "roof_is_wall_spray_receiver": false,
        "roof_world_solid_landing": true,
        "eligible_render_layer": 2,
        "noneligible_render_layer": 1,
        "terrain_geometry_and_ownership_unchanged": true
      },
      "truth_boundary": {
        "as_built_fidelity_claimed": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "capture_time_recognition_credit": false,
        "capture_time_candidate_promoted": false,
        "reference_pixels_packaged": false,
        "receiver_complete_inferred_from_art": false,
        "game_distinctive_claimed": false,
        "unobserved_sides_protected": true,
        "unsurveyed_dimensions_and_counts_are_production_inference": true,
        "direct_continuous_outgoing_land_contact_ownership_claimed": false
      }
    },
    "acceptance": {
      "evidence_manifest_sha256": "ec327adb9239a902f40fd7e2ede7afedcd19bf1869b392e9646544721eaec316",
      "motion_telemetry_manifest_sha256": "0ad7ff068f42b8230ba724d9143c9c563130de3c9d40c37837f1ed21f95ecc60",
      "visual_motion_manifest_sha256": "6a057c2b0236e90d11861499c299b723b35da37ee3590a0a154d0c3390f0b2cb",
      "package_verification_receipt_sha256": "9be91b038dc142ac84d3947ed68733c2346aa5756e4ccbb433bf0a173b8ca364",
      "evidence_tree_sha256": "464224831dfadcc4657fdb3575fc47501190ad41c44163a7dd05885284772689",
      "mechanical_review_receipt_sha256": "c2c4ee90347b458e44fda87d900a4a2031b2cf4883c16a0db1ceac0ffeec02cd",
      "review_receipt_sha256": "c7b5079a3a59847b80e201ef8107928381f9370dd74001f2675f0c68de82dbc8",
      "capture_time_recognition_metric": "13/213",
      "numerator_effect": 0,
      "review_id": "d5-1394-fidelity-quality-candidate-2026-09-10-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "receipt": {
      "evidence_manifest_sha256": "ec327adb9239a902f40fd7e2ede7afedcd19bf1869b392e9646544721eaec316",
      "motion_telemetry_manifest_sha256": "0ad7ff068f42b8230ba724d9143c9c563130de3c9d40c37837f1ed21f95ecc60",
      "visual_motion_manifest_sha256": "6a057c2b0236e90d11861499c299b723b35da37ee3590a0a154d0c3390f0b2cb",
      "package_verification_receipt_sha256": "9be91b038dc142ac84d3947ed68733c2346aa5756e4ccbb433bf0a173b8ca364",
      "evidence_tree_sha256": "464224831dfadcc4657fdb3575fc47501190ad41c44163a7dd05885284772689",
      "mechanical_review_receipt_sha256": "c2c4ee90347b458e44fda87d900a4a2031b2cf4883c16a0db1ceac0ffeec02cd",
      "review_receipt_sha256": "c7b5079a3a59847b80e201ef8107928381f9370dd74001f2675f0c68de82dbc8",
      "capture_time_recognition_metric": "13/213",
      "numerator_effect": 0,
      "unit_id": "physical-building:w96215646",
      "evidence_manifest_path": "evidence/first-playable/d5-1394-fidelity-quality-candidate-2026-09-10-001/capture-manifest.json",
      "motion_telemetry_manifest_path": "evidence/first-playable/d5-1394-fidelity-quality-candidate-2026-09-10-001/motion-telemetry.json",
      "visual_motion_manifest_path": "evidence/first-playable/d5-1394-fidelity-quality-candidate-2026-09-10-001/visual-motion.json",
      "package_verification_receipt_path": "evidence/first-playable/d5-1394-fidelity-quality-candidate-2026-09-10-001/package-verification-receipt.json",
      "evidence_tree_path": "evidence/first-playable/d5-1394-fidelity-quality-candidate-2026-09-10-001/evidence-tree.json",
      "mechanical_review_receipt_path": "evidence/first-playable/d5-1394-fidelity-quality-candidate-2026-09-10-001/mechanical-review.json",
      "review_path": "evidence/first-playable/d5-1394-fidelity-quality-candidate-2026-09-10-001/unit-visual-attestation.json"
    },
    "tree_document_sha256": "4811d4fa41523ee524b4360b9373d4a9f5daf6450e427887df3547a23570abdd",
    "image_count": 14
  },
  {
    "number": "1317",
    "source": "w95934125",
    "wall": "building:w95934125:wall",
    "roof": "building:w95934125:roof",
    "unit_id": "physical-building:w95934125",
    "adapter_id": "active-adapter:d5-1317-live:building:w95934125:wall",
    "mode": "active_d5_1317_paired_replacement",
    "files": {
      "adapter": "game/scripts/world/facades/d5_1317_gateview_live_replacement.gd",
      "config": "game/resources/facades/d5_1317_gateview_live_replacement.json",
      "factory": "game/scripts/world/facades/d5_1317_gateview_live_factory.gd",
      "factory_config": "game/resources/facades/d5_1317_gateview_quality_study.json",
      "shader": "game/resources/facades/d5_1317_siding_marks.gdshader",
      "site_kit": "game/scripts/world/facades/site_12_housing_kit.gd",
      "geometry": "game/resources/facades/d5_1317_quality_study_geometry.json",
      "surface_shader": "game/resources/facades/d5_1317_surface_tone.gdshader"
    },
    "hashes": {
      "adapter": "283a020492c03fde62c591ea9ebcb1e5c5403a55aca514f0998908b440d9e819",
      "config": "d15f6ea9e14ca9723dfd3f5794718fab6ad6d0cbf24091ce0e81fd34821e554f",
      "factory": "80930edee46371825bfb7b337b94bdbb4e3b7fc064aa2ba3061b6a86886af884",
      "factory_config": "33b54fb72cf829e933a0e386e984f6ffe9d9a7c9d335ecb034e779c12bf89a26",
      "shader": "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e",
      "site_kit": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
      "geometry": "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9",
      "surface_shader": "2388fbee5821352c30ec5925f4ff159439090c8cb1f4973344a947c65b4e4da0"
    },
    "config": {
      "schema_version": "ti.d5-1317-gateview-live-replacement/1",
      "adapter_id": "active-adapter:d5-1317-live:building:w95934125:wall",
      "source_key": "w95934125",
      "chunk_id": "x_-3__z_-2",
      "chunk_sha256": "35bf23d64e860d39c5b79a98be7830f4f477143f7e9490c6739dec0627062d11",
      "canonical_records": {
        "building:w95934125:wall": "3537997ae045f8022bbe4c6449cec82655797411e417397d15ace85fedc3a6ef",
        "building:w95934125:roof": "ae444960fc7ae2d8cae3a7fa28637ecd06b9c17d691d3c69c146564d5c6874ef",
        "area:r17241151:x_-3__z_-2": "336bb7c5d763d853c19184da045cf4a114f25493ecf02a367ca1e0523d8bebd1",
        "area:r17241152:x_-3__z_-2": "104faf44f5234729b0411e75595abeec1888f867d0efa6a3d765aaa4f93d991e",
        "land:w26767313:x_-3__z_-2": "9ff2ddf4241136939a8dbe377679ef9f30e4c17e229b91ffbafc117c03d47c04"
      },
      "accepted_art002_files": {
        "game/scripts/world/facades/d5_1317_gateview_quality_study.gd": "d43dd7045297c9c91bfac81006a189165f11b9a46de8ff537996f86e1d86dd68",
        "game/resources/facades/d5_1317_gateview_quality_study.json": "33b54fb72cf829e933a0e386e984f6ffe9d9a7c9d335ecb034e779c12bf89a26",
        "game/resources/facades/d5_1317_quality_study_geometry.json": "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9",
        "game/resources/facades/d5_1317_siding_marks.gdshader": "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e",
        "game/resources/facades/d5_1317_surface_tone.gdshader": "2388fbee5821352c30ec5925f4ff159439090c8cb1f4973344a947c65b4e4da0"
      },
      "accepted_static_review_sha256": "6eda0c3025624b6affeeafa686df46a8f4a26cef9a8d99d39bd921794026e94c",
      "accepted_source_review_sha256": "ea189ed889128cb979d7e2a59511cb9d3c930471c527a2e7079311adba4ff787",
      "pair_contract": {
        "meshes": 14,
        "surfaces": 14,
        "triangles": 1938,
        "bodies": 2,
        "shapes": 5,
        "collision_triangles": 1038,
        "wall_shapes": [
          68,
          192,
          648
        ],
        "roof_shapes": [
          22,
          108
        ],
        "eligible_source_wall_triangles": 68,
        "ground_visual_only_triangles": 36,
        "factory_calls": 1,
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "stack_allowed": false
      },
      "truth_boundary": {
        "captured_authority_metric": "13/213",
        "candidate_credit": 0,
        "runtime_attachment": true,
        "production_attachment_review": "pending",
        "recognition_accepted": false,
        "as_built_claim": false,
        "interior_modeled": false
      },
      "package_boundary": {
        "source_photography": false,
        "discovery_dependency": false,
        "activation_flag": false,
        "missing_pair_loaded_from_disk": false
      }
    },
    "behavior": {
      "schema_version": "ti.d5-1317-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "4fcdd7f900dfadb12187f558bf0e545038d8386134ed1e7f9830810be763ddb5",
        "motion_telemetry_manifest_sha256": "a1e3d98ebacaf73c5fb985a2fa2ee4597fe4c2b334cc102c3d3ea460bf361214",
        "visual_motion_manifest_sha256": "088c0a0df84440cf2ddb35996aabc5d1b1aa5e1fcafe47217cd92dbbca08fc15",
        "package_verification_receipt_sha256": "d6041941c9ec59d6a6d8fac4cbb79964fe842cdc135baf5c7a36df3a65a2c98e",
        "evidence_tree_sha256": "18da75ad3394e86f3129449bbf113efd14d2e845acd767acba995545b3e5f6ee",
        "mechanical_review_receipt_sha256": "7cd3ef79e13c19bbb34b601338f86533b9de429d274d35e55e8e6f8fbd8afdce",
        "review_receipt_sha256": "19edda17a50fd957ec09bd9a2ea310b7f82524e717c63467d5198e2e3f9500df",
        "accepted_physical_unit_id": "physical-building:w95934125",
        "capture_time_recognition_metric": "13/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w95934125",
        "wall_object_key": "building:w95934125:wall",
        "roof_object_key": "building:w95934125:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": true,
        "mapped_public_run_indices": [
          10,
          13,
          14,
          15,
          17,
          20,
          22,
          24,
          26,
          27,
          29,
          31
        ],
        "protected_run_indices": [
          0,
          1,
          2,
          3,
          4,
          5,
          6,
          7,
          8,
          9,
          11,
          12,
          16,
          18,
          19,
          21,
          23,
          25,
          28,
          30,
          32,
          33
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1
      },
      "geometry_contract": {
        "source_geometry_sha256": "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9",
        "canonical_wall_record_sha256": "3537997ae045f8022bbe4c6449cec82655797411e417397d15ace85fedc3a6ef",
        "canonical_roof_record_sha256": "ae444960fc7ae2d8cae3a7fa28637ecd06b9c17d691d3c69c146564d5c6874ef",
        "canonical_terrain_records": {
          "area:r17241151:x_-3__z_-2": "336bb7c5d763d853c19184da045cf4a114f25493ecf02a367ca1e0523d8bebd1",
          "area:r17241152:x_-3__z_-2": "104faf44f5234729b0411e75595abeec1888f867d0efa6a3d765aaa4f93d991e",
          "land:w26767313:x_-3__z_-2": "9ff2ddf4241136939a8dbe377679ef9f30e4c17e229b91ffbafc117c03d47c04"
        },
        "horizontal_source_footprint_preserved": true,
        "visual_mesh_instances": 14,
        "visual_surfaces": 14,
        "visual_triangles": 1938,
        "world_records": 735,
        "world_mesh_instances": 1018,
        "world_surfaces": 1033,
        "world_triangles": 81761,
        "world_static_bodies": 466,
        "world_shapes": 477,
        "world_topology_scope": "pre_station48_integration_live_parity",
        "capture_isolated_world_mesh_instances": 1005,
        "capture_isolated_world_surfaces": 1020,
        "capture_isolated_world_triangles": 78224,
        "capture_isolated_world_shapes": 475
      },
      "ownership_contract": {
        "structural_owner_count": 2,
        "shape_count": 5,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "eligible_source_wall",
          "noneligible_canopies_posts_braces",
          "noneligible_closed_lower_modules"
        ],
        "wall_shape_collision_triangles": [
          68,
          192,
          648
        ],
        "roof_shape_order": [
          "exact_source_roof",
          "added_public_roof"
        ],
        "roof_shape_collision_triangles": [
          22,
          108
        ],
        "eligible_exterior_collision_triangles": 68,
        "noneligible_canopy_post_collision_triangles": 192,
        "noneligible_closed_lower_collision_triangles": 648,
        "wall_collision_triangles": 908,
        "roof_collision_triangles": 130,
        "visual_ground_triangles": 36,
        "added_ground_collision_triangles": 0,
        "roof_is_wall_spray_receiver": false,
        "roof_world_solid_landing": true,
        "eligible_render_layer": 2,
        "noneligible_render_layer": 1,
        "terrain_geometry_and_ownership_unchanged": true
      },
      "truth_boundary": {
        "as_built_fidelity_claimed": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "capture_time_recognition_credit": false,
        "capture_time_candidate_promoted": false,
        "reference_pixels_packaged": false,
        "receiver_complete_inferred_from_art": false,
        "game_distinctive_claimed": false,
        "unobserved_sides_protected": true,
        "unsurveyed_dimensions_and_counts_are_production_inference": true,
        "direct_continuous_outgoing_land_contact_ownership_claimed": false,
        "continuous_motion_review_claimed": false
      }
    },
    "acceptance": {
      "evidence_manifest_sha256": "4fcdd7f900dfadb12187f558bf0e545038d8386134ed1e7f9830810be763ddb5",
      "motion_telemetry_manifest_sha256": "a1e3d98ebacaf73c5fb985a2fa2ee4597fe4c2b334cc102c3d3ea460bf361214",
      "visual_motion_manifest_sha256": "088c0a0df84440cf2ddb35996aabc5d1b1aa5e1fcafe47217cd92dbbca08fc15",
      "package_verification_receipt_sha256": "d6041941c9ec59d6a6d8fac4cbb79964fe842cdc135baf5c7a36df3a65a2c98e",
      "evidence_tree_sha256": "18da75ad3394e86f3129449bbf113efd14d2e845acd767acba995545b3e5f6ee",
      "mechanical_review_receipt_sha256": "7cd3ef79e13c19bbb34b601338f86533b9de429d274d35e55e8e6f8fbd8afdce",
      "review_receipt_sha256": "19edda17a50fd957ec09bd9a2ea310b7f82524e717c63467d5198e2e3f9500df",
      "capture_time_recognition_metric": "13/213",
      "numerator_effect": 1,
      "review_id": "d5-1317-quality-candidate-2026-09-10-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "receipt": {
      "evidence_manifest_sha256": "4fcdd7f900dfadb12187f558bf0e545038d8386134ed1e7f9830810be763ddb5",
      "motion_telemetry_manifest_sha256": "a1e3d98ebacaf73c5fb985a2fa2ee4597fe4c2b334cc102c3d3ea460bf361214",
      "visual_motion_manifest_sha256": "088c0a0df84440cf2ddb35996aabc5d1b1aa5e1fcafe47217cd92dbbca08fc15",
      "package_verification_receipt_sha256": "d6041941c9ec59d6a6d8fac4cbb79964fe842cdc135baf5c7a36df3a65a2c98e",
      "evidence_tree_sha256": "18da75ad3394e86f3129449bbf113efd14d2e845acd767acba995545b3e5f6ee",
      "mechanical_review_receipt_sha256": "7cd3ef79e13c19bbb34b601338f86533b9de429d274d35e55e8e6f8fbd8afdce",
      "review_receipt_sha256": "19edda17a50fd957ec09bd9a2ea310b7f82524e717c63467d5198e2e3f9500df",
      "capture_time_recognition_metric": "13/213",
      "numerator_effect": 1,
      "unit_id": "physical-building:w95934125",
      "evidence_manifest_path": "evidence/first-playable/d5-1317-quality-candidate-2026-09-10-001/capture-manifest.json",
      "motion_telemetry_manifest_path": "evidence/first-playable/d5-1317-quality-candidate-2026-09-10-001/motion-telemetry.json",
      "visual_motion_manifest_path": "evidence/first-playable/d5-1317-quality-candidate-2026-09-10-001/visual-motion.json",
      "package_verification_receipt_path": "evidence/first-playable/d5-1317-quality-candidate-2026-09-10-001/package-verification-receipt.json",
      "evidence_tree_path": "evidence/first-playable/d5-1317-quality-candidate-2026-09-10-001/evidence-tree.json",
      "mechanical_review_receipt_path": "evidence/first-playable/d5-1317-quality-candidate-2026-09-10-001/mechanical-review.json",
      "review_path": "evidence/first-playable/d5-1317-quality-candidate-2026-09-10-001/unit-visual-attestation.json"
    },
    "tree_document_sha256": "5ede3855f36303854396ee62c7cdd91ab561e3492a24d2c15db0d4aeab40359d",
    "image_count": 17
  },
  {
    "number": "station48",
    "source": "w764313741",
    "wall": "building:w764313741:wall",
    "roof": "building:w764313741:roof",
    "unit_id": "physical-building:w764313741",
    "adapter_id": "active-adapter:fire-station48-live:building:w764313741:wall",
    "mode": "active_fire_station48_paired_replacement",
    "attachment_kind": "active_fire_station48_paired_wall_roof_replacement",
    "source_chunk": {
      "path": "generated/world/chunks/x_0__z_-2.json",
      "sha256": "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456"
    },
    "files": {
      "adapter": "game/scripts/world/facades/fire_station48_live_replacement.gd",
      "config": "game/resources/facades/fire_station48_live_replacement.json",
      "factory": "game/scripts/world/facades/fire_station48_live_factory.gd",
      "factory_config": "game/resources/facades/fire_station48_quality_study.json",
      "shader": "game/resources/facades/fire_station48_upper_cladding.gdshader",
      "site_kit": "game/scripts/world/facades/site_12_housing_kit.gd",
      "geometry": "game/resources/facades/fire_station48_study_geometry.json"
    },
    "hashes": {
      "adapter": "163db6f19bb7368f5aa271282c11d4028337d48cc1b2e3d37b8231e1c329d25a",
      "config": "4b31025a80909b03b882c089bf17d50dbc6a4ee9d32fa9b072b884fd4eec061a",
      "factory": "33c945be3699fe7f94874d7a65ff0d01963092d0c0cb85deacaf4f794d9996d5",
      "factory_config": "2ae853642ed360f81ea6dfe53089fa909531af8776f40462fb129076f16b6795",
      "shader": "4600d14f6d45455c56ce400cc2b073c124462eee1da0e33f7492b356614f319e",
      "site_kit": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
      "geometry": "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597"
    },
    "config": {
      "adapter_id": "active-adapter:fire-station48-live:building:w764313741:wall",
      "all_additions_render_only": true,
      "candidate_credit": 0,
      "captured_authority_metric": "14/213",
      "geometry_sha256": "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597",
      "mapped_public_runs": [
        0,
        1,
        2,
        3,
        5,
        6,
        8,
        9,
        24,
        25
      ],
      "mesh_triangles": {
        "CompletePaleWindowSurrounds": 624,
        "ExactSourceNeutralRoof": 10,
        "ObservedWSWNNWPaleWallFields": 20,
        "OpaqueHighWindowGlass": 156,
        "ProtectedExactNeutralWallRuns": 32,
        "ThinStraightPublicRoofEdge": 92,
        "ThinWindowMullions": 156
      },
      "pair_partition": {
        "roof": [
          1,
          10,
          1,
          1,
          10
        ],
        "wall": [
          6,
          1080,
          1,
          1,
          52
        ]
      },
      "protected_runs": [
        4,
        7,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23
      ],
      "recognition_accepted": false,
      "record_sha256": {
        "building:w764313741:roof": "a64186052e8331d3ee744718f19ba8dc6350da4f67c8b51f29b9469c903c89d2",
        "building:w764313741:wall": "0e3b5283ff9c055dc0a642d3608af13057ed6d1c87293d4b845991d9e96f9a8d"
      },
      "schema_version": "ti.fire-station48-live-replacement/1",
      "source_collision_only": true,
      "source_key": "w764313741",
      "study_config_sha256": "2ae853642ed360f81ea6dfe53089fa909531af8776f40462fb129076f16b6795",
      "target_chunk_id": "x_0__z_-2"
    },
    "behavior": {
      "schema_version": "ti.fire-station48-production-live-parity/1",
      "acceptance_contract": {
        "evidence_manifest_sha256": "f68b77fa5c6e8983288ad9f9ca36a4fd827e716cc1c99877270eeceb547786b6",
        "motion_telemetry_manifest_sha256": "4e3a0ea032384bc1381468db84ae15c4ebc1eb75212a9fec20156d165414b028",
        "visual_motion_manifest_sha256": "708692fe592b56c9b18cbf5d9bbc086dadb1c053153d37afbd5c37c6a91c0a3e",
        "package_verification_receipt_sha256": "502c87a102c90ef446a1e3415b1bb6eca7050d46689c550c18609c3c9dc43b0b",
        "evidence_tree_sha256": "6e8e1a6d8ff3ee12e961d7adaa78cdc72e8aa57dbb607251d5a1361c171eb895",
        "mechanical_review_receipt_sha256": "fb4802671d8ec92d2cdff091a221fc6fe8f3d1dae6780446aa5604227f7cfed4",
        "review_receipt_sha256": "cb06367c7de02d2379c855dfe33915d8bd54b85a33666f0582e949752f9310cf",
        "accepted_physical_unit_id": "physical-building:w764313741",
        "capture_time_recognition_metric": "14/213",
        "numerator_effect": 1,
        "reference_recognizable": true,
        "wall_and_roof_are_one_physical_unit": true
      },
      "replacement_contract": {
        "source_key": "w764313741",
        "wall_object_key": "building:w764313741:wall",
        "roof_object_key": "building:w764313741:roof",
        "actual_supplied_chunk_pair_required": true,
        "actual_land_and_area_records_required": false,
        "mapped_public_run_indices": [
          0,
          1,
          2,
          3,
          5,
          6,
          8,
          9,
          24,
          25
        ],
        "protected_run_indices": [
          4,
          7,
          10,
          11,
          12,
          13,
          14,
          15,
          16,
          17,
          18,
          19,
          20,
          21,
          22,
          23
        ],
        "partial_pair_allowed": false,
        "fallback_allowed": false,
        "generic_stack_allowed": false,
        "factory_calls": 1
      },
      "geometry_contract": {
        "source_geometry_sha256": "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597",
        "canonical_wall_record_sha256": "0e3b5283ff9c055dc0a642d3608af13057ed6d1c87293d4b845991d9e96f9a8d",
        "canonical_roof_record_sha256": "a64186052e8331d3ee744718f19ba8dc6350da4f67c8b51f29b9469c903c89d2",
        "source_chunk_sha256": "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456",
        "horizontal_source_footprint_preserved": true,
        "original_source_channels_and_roof_preserved": true,
        "visual_mesh_instances": 7,
        "visual_surfaces": 7,
        "visual_triangles": 1090,
        "world_records": 735,
        "world_mesh_instances": 1023,
        "world_surfaces": 1038,
        "world_triangles": 82789,
        "world_static_bodies": 466,
        "world_shapes": 477,
        "world_topology_scope": "current_integration_topology"
      },
      "ownership_contract": {
        "structural_owner_count": 2,
        "shape_count": 2,
        "spray_owner_count": 1,
        "navigation_owner_count": 0,
        "wall_is_sole_spray_receiver": true,
        "wall_decal_cull_mask": 2,
        "wall_shape_order": [
          "exact_eligible_source_wall"
        ],
        "wall_shape_collision_triangles": [
          52
        ],
        "roof_shape_order": [
          "exact_noneligible_source_roof"
        ],
        "roof_shape_collision_triangles": [
          10
        ],
        "eligible_exterior_collision_triangles": 52,
        "wall_collision_triangles": 52,
        "roof_collision_triangles": 10,
        "added_collision_triangles": 0,
        "all_additions_render_only": true,
        "visual_ground_triangles": 0,
        "added_ground_collision_triangles": 0,
        "roof_is_wall_spray_receiver": false,
        "roof_world_solid_landing": true,
        "eligible_render_layer": 2,
        "noneligible_render_layer": 1,
        "terrain_geometry_and_ownership_unchanged": true
      },
      "truth_boundary": {
        "as_built_fidelity_claimed": false,
        "interior_modeled": false,
        "hidden_schedule_invented": false,
        "capture_time_recognition_credit": false,
        "capture_time_candidate_promoted": false,
        "reference_pixels_packaged": false,
        "receiver_complete_inferred_from_art": false,
        "game_distinctive_claimed": false,
        "unobserved_sides_protected": true,
        "unsurveyed_dimensions_and_counts_are_production_inference": true,
        "continuous_motion_review_claimed": false,
        "ground_to_roof_traversal_claimed": false,
        "roof_support_setup_is_separate": true,
        "spray_input_event_dispatch_claimed": false
      }
    },
    "acceptance": {
      "evidence_manifest_sha256": "f68b77fa5c6e8983288ad9f9ca36a4fd827e716cc1c99877270eeceb547786b6",
      "motion_telemetry_manifest_sha256": "4e3a0ea032384bc1381468db84ae15c4ebc1eb75212a9fec20156d165414b028",
      "visual_motion_manifest_sha256": "708692fe592b56c9b18cbf5d9bbc086dadb1c053153d37afbd5c37c6a91c0a3e",
      "package_verification_receipt_sha256": "502c87a102c90ef446a1e3415b1bb6eca7050d46689c550c18609c3c9dc43b0b",
      "evidence_tree_sha256": "6e8e1a6d8ff3ee12e961d7adaa78cdc72e8aa57dbb607251d5a1361c171eb895",
      "mechanical_review_receipt_sha256": "fb4802671d8ec92d2cdff091a221fc6fe8f3d1dae6780446aa5604227f7cfed4",
      "review_receipt_sha256": "cb06367c7de02d2379c855dfe33915d8bd54b85a33666f0582e949752f9310cf",
      "capture_time_recognition_metric": "14/213",
      "numerator_effect": 1,
      "review_id": "fire-station48-quality-candidate-2026-09-11-001",
      "review_kind": "independent_reference_recognition",
      "status": "accept"
    },
    "receipt": {
      "evidence_manifest_sha256": "f68b77fa5c6e8983288ad9f9ca36a4fd827e716cc1c99877270eeceb547786b6",
      "motion_telemetry_manifest_sha256": "4e3a0ea032384bc1381468db84ae15c4ebc1eb75212a9fec20156d165414b028",
      "visual_motion_manifest_sha256": "708692fe592b56c9b18cbf5d9bbc086dadb1c053153d37afbd5c37c6a91c0a3e",
      "package_verification_receipt_sha256": "502c87a102c90ef446a1e3415b1bb6eca7050d46689c550c18609c3c9dc43b0b",
      "evidence_tree_sha256": "6e8e1a6d8ff3ee12e961d7adaa78cdc72e8aa57dbb607251d5a1361c171eb895",
      "mechanical_review_receipt_sha256": "fb4802671d8ec92d2cdff091a221fc6fe8f3d1dae6780446aa5604227f7cfed4",
      "review_receipt_sha256": "cb06367c7de02d2379c855dfe33915d8bd54b85a33666f0582e949752f9310cf",
      "capture_time_recognition_metric": "14/213",
      "numerator_effect": 1,
      "unit_id": "physical-building:w764313741",
      "evidence_manifest_path": "evidence/first-playable/fire-station48-quality-candidate-2026-09-11-001/capture-manifest.json",
      "motion_telemetry_manifest_path": "evidence/first-playable/fire-station48-quality-candidate-2026-09-11-001/motion-telemetry.json",
      "visual_motion_manifest_path": "evidence/first-playable/fire-station48-quality-candidate-2026-09-11-001/visual-motion.json",
      "package_verification_receipt_path": "evidence/first-playable/fire-station48-quality-candidate-2026-09-11-001/package-verification-receipt.json",
      "evidence_tree_path": "evidence/first-playable/fire-station48-quality-candidate-2026-09-11-001/evidence-tree.json",
      "mechanical_review_receipt_path": "evidence/first-playable/fire-station48-quality-candidate-2026-09-11-001/mechanical-review.json",
      "review_path": "evidence/first-playable/fire-station48-quality-candidate-2026-09-11-001/unit-visual-attestation.json"
    },
    "tree_document_sha256": "9dae353459301e65690a44a3665d41ea4a8d5adf688799df3b1e57247f50173d",
    "image_count": 17
  }
]);
const D5_BATCH_BUILDER_SHA256 = "8059a635b6f0b5ff272f1de1a7d0b4531c6b44111755efeefad3aaedc1741619";

const REVIEW_RECEIPTS = Object.freeze({
  ...Object.fromEntries(D5_BATCH_ACCEPTED.map((d) => [d.acceptance.review_id, Object.freeze(d.receipt)])),
  "building-1-hero-2026-09-04:main": Object.freeze({
    evidence_manifest_path: "evidence/first-playable/building-1-hero-2026-09-04/capture-manifest.json",
    evidence_manifest_sha256: "ebeef887b37c6845c6c8fa3f25e06706351fe7c1dab0e1a3b0eaf47dfb773017",
    review_path: "evidence/first-playable/building-1-hero-2026-09-04/INDEPENDENT_REVIEW.md",
    review_receipt_sha256: "b12858438d6522b7f3cf42fa06392648d16ee3e0c418eb5e807a3ee1be770c2a",
    unit_id: "physical-building:r16681702",
  }),
  "building-1-tower-grounded-correction-2026-09-04": Object.freeze({
    evidence_manifest_path: "evidence/first-playable/building-1-tower-grounded-correction-2026-09-04/capture-manifest.json",
    evidence_manifest_sha256: "dbe9745f5356b2309e820c2b47987ee4463518eaf4afd77fcd37df0edc8d437a",
    review_path: "evidence/first-playable/building-1-tower-grounded-correction-2026-09-04/INDEPENDENT_REVIEW.md",
    review_receipt_sha256: "fb952a31151805078d1e386117ed965aa0649ffddcd17874d13493b5dd4239bb",
    unit_id: "physical-building:w1222720021",
  }),
  "building-3-hero-massing-2026-09-04": Object.freeze({
    evidence_manifest_path: "evidence/first-playable/building-3-hero-massing-2026-09-04/capture-manifest.json",
    evidence_manifest_sha256: "4b92b71df3c7f8f7dfbb285bd7566b3f422a32be45f810d532328e15d008f5be",
    review_path: "evidence/first-playable/building-3-hero-massing-2026-09-04/INDEPENDENT_REVIEW.md",
    review_receipt_sha256: "1aee23943b3df4f600b9a4e4fce86d839b75ce575a924de4ca8b187bd9120046",
    unit_id: "physical-building:w34313540",
  }),
  "p1-existing-live-revalidation-2026-09-04:hawkins": Object.freeze({
    evidence_manifest_path: "evidence/first-playable/p1-existing-live-revalidation-2026-09-04/capture-manifest.json",
    evidence_manifest_sha256: "e1ab8f526aed22a6234fff1d2fcc5eae5d2245df4260a25a5705cd37a158a921",
    review_path: "evidence/first-playable/p1-existing-live-revalidation-2026-09-04/INDEPENDENT_REVIEW.md",
    review_receipt_sha256: "9e4364eaf78412c58bfcac1bad1f4f35241f48a1b373976cdfa42638ce57b680",
    unit_id: "physical-building:w1249412093",
  }),
  "isle-house-variant-c-live-replacement-2026-09-04": Object.freeze({
    evidence_manifest_path: "evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04/capture-manifest.json",
    evidence_manifest_sha256: "23fd6eff4ab8d9696af9d1ecc19bea50537cc824ecf3a7bebdf4fa191cd039d9",
    review_path: "evidence/first-playable/isle-house-composite-repair-variant-c-live-replacement-2026-09-04/INDEPENDENT_LIVE_BAR_RAISER_REVIEW.md",
    review_receipt_sha256: ISLE_HOUSE_LIVE_REVIEW_RECEIPT_SHA256,
    unit_id: ISLE_HOUSE_UNIT_ID,
  }),
  "navy-chapel-187-live-replacement-2026-09-04": Object.freeze({
    evidence_manifest_path: "evidence/first-playable/navy-chapel-187-live-replacement-2026-09-04/capture-manifest.json",
    evidence_manifest_sha256: "54d434c9283a0e2d86aa836e6a21672a8756e5a170cb5724d66066e799223930",
    review_path: "evidence/first-playable/navy-chapel-187-live-replacement-2026-09-04/INDEPENDENT_LIVE_BAR_RAISER_REVIEW.md",
    review_receipt_sha256: NAVY_CHAPEL_LIVE_REVIEW_RECEIPT_SHA256,
    unit_id: "physical-building:w291189336",
  }),
  "d1-b201-live-attachment-2026-09-04": Object.freeze({
    evidence_manifest_path: "evidence/first-playable/d1-b201-live-attachment-2026-09-04/capture-manifest.json",
    evidence_manifest_sha256: D1_B201_EVIDENCE_MANIFEST_SHA256,
    review_path: "evidence/first-playable/d1-b201-live-attachment-2026-09-04/INDEPENDENT_LIVE_VISUAL_BAR_RAISER_REVIEW.md",
    review_receipt_sha256: D1_B201_LIVE_REVIEW_RECEIPT_SHA256,
    unit_id: "physical-building:w34313545",
  }),
  "d1-b225-production-attachment-v7-staging-2026-09-05": Object.freeze({
    capture_time_recognition_metric: "7/213",
    evidence_manifest_path: "evidence/first-playable/d1-b225-production-attachment-v7-staging-2026-09-05/capture-manifest.json",
    evidence_manifest_sha256: D1_B225_EVIDENCE_MANIFEST_SHA256,
    evidence_tree_sha256: D1_B225_EVIDENCE_TREE_SHA256,
    numerator_effect: 1,
    review_path: "evidence/reviews/d1-b225-production-attachment-v7-staging-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md",
    review_receipt_sha256: D1_B225_LIVE_REVIEW_RECEIPT_SHA256,
    unit_id: "physical-building:w95934119",
  }),
  [D2_1441_REVIEW_ID]: Object.freeze({
    capture_time_recognition_metric: "8/213",
    evidence_manifest_path: D2_1441_EVIDENCE_MANIFEST_PATH,
    evidence_manifest_sha256: D2_1441_EVIDENCE_MANIFEST_SHA256,
    evidence_tree_sha256: D2_1441_EVIDENCE_TREE_SHA256,
    mechanical_review_path: D2_1441_MECHANICAL_REVIEW_PATH,
    mechanical_review_receipt_sha256: D2_1441_MECHANICAL_REVIEW_RECEIPT_SHA256,
    motion_telemetry_manifest_path: D2_1441_MOTION_TELEMETRY_MANIFEST_PATH,
    motion_telemetry_manifest_sha256: D2_1441_MOTION_TELEMETRY_MANIFEST_SHA256,
    numerator_effect: 1,
    package_verification_receipt_path: D2_1441_PACKAGE_VERIFICATION_RECEIPT_PATH,
    package_verification_receipt_sha256: D2_1441_PACKAGE_VERIFICATION_RECEIPT_SHA256,
    review_path: D2_1441_VISUAL_REVIEW_PATH,
    review_receipt_sha256: D2_1441_VISUAL_REVIEW_RECEIPT_SHA256,
    unit_id: "physical-building:w95934105",
    visual_motion_manifest_path: D2_1441_VISUAL_MOTION_MANIFEST_PATH,
    visual_motion_manifest_sha256: D2_1441_VISUAL_MOTION_MANIFEST_SHA256,
  }),
  [D2_1439_REVIEW_ID]: Object.freeze({
    capture_time_recognition_metric: "9/213",
    evidence_manifest_path: D2_1439_EVIDENCE_MANIFEST_PATH,
    evidence_manifest_sha256: D2_1439_EVIDENCE_MANIFEST_SHA256,
    evidence_tree_sha256: D2_1439_EVIDENCE_TREE_SHA256,
    mechanical_review_path: D2_1439_MECHANICAL_REVIEW_PATH,
    mechanical_review_receipt_sha256: D2_1439_MECHANICAL_REVIEW_RECEIPT_SHA256,
    motion_telemetry_manifest_path: D2_1439_MOTION_TELEMETRY_MANIFEST_PATH,
    motion_telemetry_manifest_sha256: D2_1439_MOTION_TELEMETRY_MANIFEST_SHA256,
    numerator_effect: 1,
    package_verification_receipt_path: D2_1439_PACKAGE_VERIFICATION_RECEIPT_PATH,
    package_verification_receipt_sha256: D2_1439_PACKAGE_VERIFICATION_RECEIPT_SHA256,
    review_path: D2_1439_VISUAL_REVIEW_PATH,
    review_receipt_sha256: D2_1439_VISUAL_REVIEW_RECEIPT_SHA256,
    unit_id: "physical-building:w95934144",
    visual_motion_manifest_path: D2_1439_VISUAL_MOTION_MANIFEST_PATH,
    visual_motion_manifest_sha256: D2_1439_VISUAL_MOTION_MANIFEST_SHA256,
  }),
  [D2_1444_REVIEW_ID]: Object.freeze({
    capture_time_recognition_metric: "9/213",
    evidence_manifest_path: D2_1444_EVIDENCE_MANIFEST_PATH,
    evidence_manifest_sha256: D2_1444_EVIDENCE_MANIFEST_SHA256,
    evidence_tree_sha256: D2_1444_EVIDENCE_TREE_SHA256,
    mechanical_review_path: D2_1444_MECHANICAL_REVIEW_PATH,
    mechanical_review_receipt_sha256: D2_1444_MECHANICAL_REVIEW_RECEIPT_SHA256,
    motion_telemetry_manifest_path: D2_1444_MOTION_TELEMETRY_MANIFEST_PATH,
    motion_telemetry_manifest_sha256: D2_1444_MOTION_TELEMETRY_MANIFEST_SHA256,
    numerator_effect: 1,
    package_verification_receipt_path: D2_1444_PACKAGE_VERIFICATION_RECEIPT_PATH,
    package_verification_receipt_sha256: D2_1444_PACKAGE_VERIFICATION_RECEIPT_SHA256,
    review_path: D2_1444_VISUAL_REVIEW_PATH,
    review_receipt_sha256: D2_1444_VISUAL_REVIEW_RECEIPT_SHA256,
    unit_id: "physical-building:w95934117",
    visual_motion_manifest_path: D2_1444_VISUAL_MOTION_MANIFEST_PATH,
    visual_motion_manifest_sha256: D2_1444_VISUAL_MOTION_MANIFEST_SHA256,
  }),
});

const PATHS = Object.freeze({
  inventory: "discovery/FACADE_RECEIVER_INVENTORY.json",
  manifest: "generated/world/manifest.json",
  catalog: "discovery/facades/facade-recognition-catalog.json",
  schema: "discovery/facades/facade-recognition-catalog.schema.json",
  adapterContracts: "game/resources/facades/facade-runtime-adapter-contracts.json",
  registry: "game/resources/facades/facade-runtime-registry.json",
  report: "discovery/facades/facade-recognition-validation-report.json",
});

const EXPECTED = Object.freeze({
  active_runtime_adapter_receivers: 14,
  building_footprints: 213,
  building_parts: 2,
  composite_units: 1,
  direct_wall_receivers: 214,
  legacy_adapter_receivers: 9,
  recognition_units: 213,
  source_records: 215,
  standalone_units: 212,
  runtime_adapter_receivers: 23,
  visible_wall_runs: 4971,
});

const EXPECTED_ADAPTER_CONTRACTS = Object.freeze({
  disabled_adapter_receivers: 6,
  disabled_projection_occurrences: 13,
  disabled_unique_projection_inputs: 13,
  package_safe_adapter_receivers: 17,
  receiver_adapter_plans: 23,
});

const ADAPTER_CONTRACT_CHECK_ID = `adapter_contract_${EXPECTED_ADAPTER_CONTRACTS.package_safe_adapter_receivers}_ready_${EXPECTED_ADAPTER_CONTRACTS.disabled_adapter_receivers}_disabled_${EXPECTED_ADAPTER_CONTRACTS.disabled_unique_projection_inputs}_unique_projection_inputs`;

const CATALOG_COMPILER_CONTRACT = Object.freeze({
  emitted_runtime_schema_version: RUNTIME_SCHEMA,
  required_compiler_version: COMPILER_VERSION,
  unknown_version_policy: UNKNOWN_VERSION_POLICY,
});

const CLAIM_VOCABULARY = Object.freeze({
  as_built_fidelity: "A separate surveyed/as-built claim; unclaimed by the Phase 1 seed.",
  game_distinctive: "Distinguishable inside the game; never evidence of real-world recognizability.",
  receiver_complete: "Every physical recognition unit is bound to its exact frozen generated wall receiver or receivers.",
  reference_recognizable: "An ordinary gameplay view is independently matched to target-identifiable reference evidence.",
  real_world_recognition_exclusions: [
    "address_or_name_label_only",
    "fictional_identifier",
    "generated_source_key_pattern",
    "implementation_metadata",
  ],
});

const ACTIVE_REVIEW_STATUS_SCOPE = "runtime_asset_original_detail_provenance_only_not_reference_recognition";
const ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY = "physical_unit_claim_and_independent_acceptance_record";
const ACTIVE_ADAPTER_UNIT_BY_RECEIVER = Object.freeze({
  [BUILDING_1_WALL]: unitId(BUILDING_1_SOURCE),
  [BUILDING_1_TOWER_WALL]: unitId(BUILDING_1_TOWER_SOURCE),
  [BUILDING_3_WALL]: unitId(BUILDING_3_SOURCE),
  [ISLE_HOUSE_LOW_WALL]: ISLE_HOUSE_UNIT_ID,
  [NAVY_CHAPEL_WALL]: unitId(NAVY_CHAPEL_SOURCE),
  [D1_B201_WALL]: unitId(D1_B201_SOURCE),
  [D1_B225_WALL]: unitId(D1_B225_SOURCE),
  [D2_1441_WALL]: unitId(D2_1441_SOURCE),
  [D2_1439_WALL]: unitId(D2_1439_SOURCE),
  [D2_1444_WALL]: unitId(D2_1444_SOURCE),
  "building:w764313741:wall": "physical-building:w764313741",
  "building:w95934125:wall": "physical-building:w95934125",
  "building:w96215646:wall": "physical-building:w96215646",
  "building:w95934123:wall": "physical-building:w95934123",
});
const ACTIVE_ADAPTER_REVIEW_STATUS_BY_RECEIVER = Object.freeze({
  [BUILDING_1_WALL]: "pending_independent_original_detail_review",
  [BUILDING_1_TOWER_WALL]: "pending_independent_original_detail_review",
  [BUILDING_3_WALL]: "pending_independent_original_detail_review",
  [ISLE_HOUSE_LOW_WALL]: "independent_exact_current_live_pass",
  [NAVY_CHAPEL_WALL]: "independent_exact_current_live_pass",
  [D1_B201_WALL]: "independent_exact_current_live_pass",
  [D1_B225_WALL]: "independent_exact_current_live_pass",
  [D2_1441_WALL]: "independent_exact_current_live_pass",
  [D2_1439_WALL]: "independent_exact_current_live_pass",
  [D2_1444_WALL]: "independent_exact_current_live_pass",
  "building:w764313741:wall": "independent_exact_current_live_pass",
  "building:w95934125:wall": "independent_exact_current_live_pass",
  "building:w96215646:wall": "independent_exact_current_live_pass",
  "building:w95934123:wall": "independent_exact_current_live_pass",
});

const RUNTIME_PATH_KEYS = new Set([
  "calibration_registry_path",
  "facade_layout_path",
  "facade_scene_path",
  "facade_script_path",
  "field_material_path",
  "field_shader_path",
  "material_path",
  "placement_registry_path",
  "prototype_material_path",
  "runtime_adapter_path",
  "runtime_config_path",
  "runtime_helper_path",
  "runtime_massing_override_path",
  "shader_path",
  "standalone_factory_path",
  "standalone_registry_path",
]);
const RUNTIME_PATH_PREFIXES = [
  "game/resources/",
  "game/scenes/world/",
  "game/scripts/world/",
];

function absolute(relativePath) {
  const result = resolve(ROOT, relativePath);
  invariant(
    result === ROOT || result.startsWith(`${ROOT}${sep}`),
    `Path escapes repository root: ${relativePath}`,
  );
  return result;
}

function readJson(relativePath) {
  const source = readFileSync(absolute(relativePath), "utf8");
  try {
    return JSON.parse(source);
  } catch (error) {
    throw new Error(`Invalid JSON in ${relativePath}: ${error.message}`);
  }
}

function sha256Bytes(value) {
  return createHash("sha256").update(value).digest("hex");
}

function sha256Stable(value) {
  return sha256Bytes(stableJson(value));
}

function packetTreeSha256(relativeRoot) {
  const root = absolute(relativeRoot);
  const regularFiles = [];
  function walk(directory, prefix = "") {
    for (const entry of readdirSync(directory, { withFileTypes: true })) {
      const relativePath = prefix.length === 0 ? entry.name : `${prefix}/${entry.name}`;
      const path = resolve(directory, entry.name);
      const metadata = lstatSync(path);
      invariant(!metadata.isSymbolicLink(), `Evidence packet contains a forbidden symlink: ${relativeRoot}/${relativePath}`);
      if (metadata.isDirectory()) {
        walk(path, relativePath);
      } else {
        invariant(metadata.isFile(), `Evidence packet contains an unsupported entry: ${relativeRoot}/${relativePath}`);
        regularFiles.push(relativePath);
      }
    }
  }
  walk(root);
  regularFiles.sort((left, right) => Buffer.compare(Buffer.from(left), Buffer.from(right)));
  const digest = createHash("sha256");
  for (const relativePath of regularFiles) {
    digest.update(`${sha256File(resolve(root, relativePath))}  ./${relativePath}\n`);
  }
  return { file_count: regularFiles.length, sha256: digest.digest("hex") };
}

function equalStable(left, right) {
  return stableJson(left) === stableJson(right);
}

function assertObject(value, label) {
  invariant(value != null && typeof value === "object" && !Array.isArray(value), `${label} must be an object`);
}

function assertExactKeys(value, expectedKeys, label) {
  assertObject(value, label);
  const actual = Object.keys(value).sort();
  const expected = [...expectedKeys].sort();
  invariant(equalStable(actual, expected), `${label} keys drifted: expected ${expected.join(", ")}, found ${actual.join(", ")}`);
}

function assertUnique(values, label) {
  invariant(new Set(values).size === values.length, `${label} contains duplicates`);
}

function normalizedSourceRecords(objects) {
  return objects.map((object) => {
    const relationship = object.footprint_relationship.kind;
    const role = relationship === "standalone_building_footprint"
      ? "standalone_building_footprint"
      : relationship === "composite_parent_footprint"
        ? "composite_parent_footprint"
        : "building_part_within_parent_footprint";
    return { role, source_key: object.source.source_key };
  });
}

function identityFor(object) {
  const identity = object.identity;
  const canonicalName = identity.canonical_name ?? identity.inherited_parent_name ?? null;
  const address = identity.address ?? {};
  const addressEvidence = address.completeness != null;
  return {
    address_completeness: address.completeness ?? null,
    address_evidence: addressEvidence,
    canonical_name: canonicalName,
    currentness_claimed: false,
    formatted_address: address.formatted ?? null,
    identity_confidence: identity.identity_confidence,
    name_evidence: typeof canonicalName === "string" && canonicalName.length > 0,
  };
}

function unitId(sourceKey) {
  return `physical-building:${sourceKey}`;
}

function adapterId(receiverKey) {
  return `legacy-adapter:${receiverKey}`;
}

function activeAdapterId(receiverKey) {
  return `active-adapter:building-1-hero:${receiverKey}`;
}

function building3ActiveAdapterId(receiverKey) {
  return `active-adapter:building-3-hero:${receiverKey}`;
}

function isleHouseActiveAdapterId(receiverKey) {
  return `active-adapter:isle-house-variant-c:${receiverKey}`;
}

function navyChapelActiveAdapterId(receiverKey) {
  return `active-adapter:navy-chapel-187:${receiverKey}`;
}

function d1B201ActiveAdapterId(receiverKey) {
  return `active-adapter:d1-b201-live:${receiverKey}`;
}

function d1B225ActiveAdapterId(receiverKey) {
  return `active-adapter:d1-b225-live:${receiverKey}`;
}

function d21441ActiveAdapterId(receiverKey) {
  return `active-adapter:d2-1441-live:${receiverKey}`;
}

function d21439ActiveAdapterId(receiverKey) {
  return `active-adapter:d2-1439-live:${receiverKey}`;
}

function d21444ActiveAdapterId(receiverKey) {
  return `active-adapter:d2-1444-live:${receiverKey}`;
}

function loadInputs() {
  const inventory = readJson(PATHS.inventory);
  const manifest = readJson(PATHS.manifest);
  const catalogSchema = readJson(PATHS.schema);
  assertSchemaDocument(catalogSchema, PATHS.schema);
  invariant(inventory.schema_version === "ti.facade-receiver-inventory/1", "Facade receiver inventory schema drifted");
  invariant(manifest.schema_version === "ti.godot-world/2", "Generated world manifest schema drifted");
  invariant(
    inventory.authoritative_inputs.generated_manifest.content_sha256 === manifest.content_sha256,
    "Inventory and generated manifest content identities disagree",
  );
  invariant(inventory.reconciliation.status === "pass", "Facade receiver inventory reconciliation is not passing");
  invariant(inventory.reconciliation.observed_source_entities.total === EXPECTED.source_records, "Inventory source-record count drifted");
  invariant(inventory.reconciliation.expected.building_footprints === EXPECTED.building_footprints, "Building-footprint count drifted");
  invariant(inventory.reconciliation.expected.building_parts === EXPECTED.building_parts, "Building-part count drifted");
  invariant(inventory.reconciliation.generated_direct_receivers.wall_objects === EXPECTED.direct_wall_receivers, "Direct wall-receiver count drifted");
  invariant(inventory.reconciliation.generated_wall_segments.total_visible_wall_segments === EXPECTED.visible_wall_runs, "Visible wall-run count drifted");
  invariant(Array.isArray(inventory.objects) && inventory.objects.length === EXPECTED.source_records, "Inventory objects are incomplete");
  return {
    catalogSchema,
    inventory,
    inventorySha256: sha256File(absolute(PATHS.inventory)),
    manifest,
    manifestSha256: sha256File(absolute(PATHS.manifest)),
    runtimeContracts: {
      heroAdapterPath: BUILDING_1_HERO_ADAPTER_PATH,
      heroAdapterSha256: sha256File(absolute(BUILDING_1_HERO_ADAPTER_PATH)),
      heroAdapterText: readFileSync(absolute(BUILDING_1_HERO_ADAPTER_PATH), "utf8"),
      heroConfig: readJson(BUILDING_1_HERO_CONFIG_PATH),
      heroConfigPath: BUILDING_1_HERO_CONFIG_PATH,
      heroConfigSha256: sha256File(absolute(BUILDING_1_HERO_CONFIG_PATH)),
      heroPublicFrontConfig: readJson(BUILDING_1_PUBLIC_FRONT_CONFIG_PATH),
      heroPublicFrontConfigSha256: sha256File(absolute(BUILDING_1_PUBLIC_FRONT_CONFIG_PATH)),
      heroReturnsAcceptance: readJson(B1_RETURNS_ACCEPTANCE_PATH),
      heroReturnsAcceptanceSha256: sha256File(absolute(B1_RETURNS_ACCEPTANCE_PATH)),
      packageSanitizationSourceProvenance: readJson(PACKAGE_SANITIZATION_SOURCE_PROVENANCE_PATH),
      packageSanitizationSourceProvenanceSha256: sha256File(absolute(PACKAGE_SANITIZATION_SOURCE_PROVENANCE_PATH)),
      building3Config: readJson(BUILDING_3_CONFIG_PATH),
      building3ConfigPath: BUILDING_3_CONFIG_PATH,
      building3ConfigSha256: sha256File(absolute(BUILDING_3_CONFIG_PATH)),
      building3AuthoringProvenance: readJson(BUILDING_3_AUTHORING_PROVENANCE_PATH),
      building3AuthoringProvenanceSha256: sha256File(absolute(BUILDING_3_AUTHORING_PROVENANCE_PATH)),
      building3MassingPath: BUILDING_3_MASSING_PATH,
      building3MassingSha256: sha256File(absolute(BUILDING_3_MASSING_PATH)),
      building3MassingText: readFileSync(absolute(BUILDING_3_MASSING_PATH), "utf8"),
      isleHouseConfig: readJson(ISLE_HOUSE_VARIANT_C_CONFIG_PATH),
      isleHouseConfigPath: ISLE_HOUSE_VARIANT_C_CONFIG_PATH,
      isleHouseConfigSha256: sha256File(absolute(ISLE_HOUSE_VARIANT_C_CONFIG_PATH)),
      isleHouseLiveAdapterPath: ISLE_HOUSE_LIVE_ADAPTER_PATH,
      isleHouseLiveAdapterSha256: sha256File(absolute(ISLE_HOUSE_LIVE_ADAPTER_PATH)),
      isleHouseLiveAdapterText: readFileSync(absolute(ISLE_HOUSE_LIVE_ADAPTER_PATH), "utf8"),
      isleHouseRepairFactorySha256: sha256File(absolute(ISLE_HOUSE_REPAIR_FACTORY_PATH)),
      isleHouseReviewedFactorySha256: sha256File(absolute(ISLE_HOUSE_REVIEWED_FACTORY_PATH)),
      navyChapelConfig: readJson(NAVY_CHAPEL_CONFIG_PATH),
      navyChapelConfigPath: NAVY_CHAPEL_CONFIG_PATH,
      navyChapelConfigSha256: sha256File(absolute(NAVY_CHAPEL_CONFIG_PATH)),
      navyChapelLiveAdapterPath: NAVY_CHAPEL_LIVE_ADAPTER_PATH,
      navyChapelLiveAdapterSha256: sha256File(absolute(NAVY_CHAPEL_LIVE_ADAPTER_PATH)),
      navyChapelLiveAdapterText: readFileSync(absolute(NAVY_CHAPEL_LIVE_ADAPTER_PATH), "utf8"),
      navyChapelPrototypeSha256: sha256File(absolute(NAVY_CHAPEL_PROTOTYPE_PATH)),
      d1B201Config: readJson(D1_B201_CONFIG_PATH),
      d1B201ConfigPath: D1_B201_CONFIG_PATH,
      d1B201ConfigSha256: sha256File(absolute(D1_B201_CONFIG_PATH)),
      d1B201LiveAdapterPath: D1_B201_LIVE_ADAPTER_PATH,
      d1B201LiveAdapterSha256: sha256File(absolute(D1_B201_LIVE_ADAPTER_PATH)),
      d1B201LiveAdapterText: readFileSync(absolute(D1_B201_LIVE_ADAPTER_PATH), "utf8"),
      d1B225Config: readJson(D1_B225_CONFIG_PATH),
      d1B225ConfigPath: D1_B225_CONFIG_PATH,
      d1B225ConfigSha256: sha256File(absolute(D1_B225_CONFIG_PATH)),
      d1B225LiveAdapterPath: D1_B225_LIVE_ADAPTER_PATH,
      d1B225LiveAdapterSha256: sha256File(absolute(D1_B225_LIVE_ADAPTER_PATH)),
      d1B225LiveAdapterText: readFileSync(absolute(D1_B225_LIVE_ADAPTER_PATH), "utf8"),
      d21441Config: readJson(D2_1441_CONFIG_PATH),
      d21441ConfigPath: D2_1441_CONFIG_PATH,
      d21441ConfigSha256: sha256File(absolute(D2_1441_CONFIG_PATH)),
      d21441LiveAdapterPath: D2_1441_LIVE_ADAPTER_PATH,
      d21441LiveAdapterSha256: sha256File(absolute(D2_1441_LIVE_ADAPTER_PATH)),
      d21441LiveAdapterText: readFileSync(absolute(D2_1441_LIVE_ADAPTER_PATH), "utf8"),
      d21441PrototypeSha256: sha256File(absolute(D2_1441_PROTOTYPE_PATH)),
      d21441PrototypeConfigSha256: sha256File(absolute(D2_1441_PROTOTYPE_CONFIG_PATH)),
      d21441SiteKitSha256: sha256File(absolute(D2_1441_SITE_KIT_PATH)),
      d21439Config: readJson(D2_1439_CONFIG_PATH),
      d21439ConfigPath: D2_1439_CONFIG_PATH,
      d21439ConfigSha256: sha256File(absolute(D2_1439_CONFIG_PATH)),
      d21439LiveAdapterPath: D2_1439_LIVE_ADAPTER_PATH,
      d21439LiveAdapterSha256: sha256File(absolute(D2_1439_LIVE_ADAPTER_PATH)),
      d21439LiveAdapterText: readFileSync(absolute(D2_1439_LIVE_ADAPTER_PATH), "utf8"),
      d21439PrototypeSha256: sha256File(absolute(D2_1439_PROTOTYPE_PATH)),
      d21439PrototypeConfigSha256: sha256File(absolute(D2_1439_PROTOTYPE_CONFIG_PATH)),
      d21439SiteKitSha256: sha256File(absolute(D2_1439_SITE_KIT_PATH)),
      d21444Config: readJson(D2_1444_CONFIG_PATH),
      d21444ConfigPath: D2_1444_CONFIG_PATH,
      d21444ConfigSha256: sha256File(absolute(D2_1444_CONFIG_PATH)),
      d21444LiveAdapterPath: D2_1444_LIVE_ADAPTER_PATH,
      d21444LiveAdapterSha256: sha256File(absolute(D2_1444_LIVE_ADAPTER_PATH)),
      d21444LiveAdapterText: readFileSync(absolute(D2_1444_LIVE_ADAPTER_PATH), "utf8"),
      d21444PrototypeSha256: sha256File(absolute(D2_1444_PROTOTYPE_PATH)),
      d21444PrototypeConfigSha256: sha256File(absolute(D2_1444_PROTOTYPE_CONFIG_PATH)),
      d21444SiteKitSha256: sha256File(absolute(D2_1444_SITE_KIT_PATH)),
      d21441EvidenceManifest: readJson(D2_1441_EVIDENCE_MANIFEST_PATH),
      d21441EvidenceManifestPath: D2_1441_EVIDENCE_MANIFEST_PATH,
      d21441EvidenceManifestSha256: sha256File(absolute(D2_1441_EVIDENCE_MANIFEST_PATH)),
      d21441MotionTelemetryManifest: readJson(D2_1441_MOTION_TELEMETRY_MANIFEST_PATH),
      d21441MotionTelemetryManifestPath: D2_1441_MOTION_TELEMETRY_MANIFEST_PATH,
      d21441MotionTelemetryManifestSha256: sha256File(absolute(D2_1441_MOTION_TELEMETRY_MANIFEST_PATH)),
      d21441VisualMotionManifest: readJson(D2_1441_VISUAL_MOTION_MANIFEST_PATH),
      d21441VisualMotionManifestPath: D2_1441_VISUAL_MOTION_MANIFEST_PATH,
      d21441VisualMotionManifestSha256: sha256File(absolute(D2_1441_VISUAL_MOTION_MANIFEST_PATH)),
      d21441PackageVerificationReceipt: readJson(D2_1441_PACKAGE_VERIFICATION_RECEIPT_PATH),
      d21441PackageVerificationReceiptPath: D2_1441_PACKAGE_VERIFICATION_RECEIPT_PATH,
      d21441PackageVerificationReceiptSha256: sha256File(absolute(D2_1441_PACKAGE_VERIFICATION_RECEIPT_PATH)),
      d21441MechanicalReviewPath: D2_1441_MECHANICAL_REVIEW_PATH,
      d21441MechanicalReviewSha256: sha256File(absolute(D2_1441_MECHANICAL_REVIEW_PATH)),
      d21441MechanicalReviewText: readFileSync(absolute(D2_1441_MECHANICAL_REVIEW_PATH), "utf8"),
      d21441VisualReviewPath: D2_1441_VISUAL_REVIEW_PATH,
      d21441VisualReviewSha256: sha256File(absolute(D2_1441_VISUAL_REVIEW_PATH)),
      d21441VisualReviewText: readFileSync(absolute(D2_1441_VISUAL_REVIEW_PATH), "utf8"),
      d21441EvidenceTree: packetTreeSha256(D2_1441_EVIDENCE_ROOT),
      worldBuilderPath: WORLD_CHUNK_BUILDER_PATH,
      acceptedWorldBuilderSha256: D2_1441_REVIEWED_WORLD_BUILDER_SHA256,
      currentWorldBuilderSha256: sha256File(absolute(WORLD_CHUNK_BUILDER_PATH)),
      worldBuilderText: readFileSync(absolute(WORLD_CHUNK_BUILDER_PATH), "utf8"),
    },
  };
}

function loadWallReceivers(manifest) {
  invariant(Array.isArray(manifest.chunks) && manifest.chunks.length === 38, "Generated chunk descriptor count drifted");
  const receiverByKey = new Map();
  for (const descriptor of manifest.chunks) {
    const relativePath = `generated/world/${descriptor.path}`;
    const path = absolute(relativePath);
    invariant(existsSync(path) && statSync(path).isFile(), `Missing generated chunk ${relativePath}`);
    invariant(statSync(path).size === descriptor.bytes, `Generated chunk byte count drifted: ${relativePath}`);
    invariant(sha256File(path) === descriptor.sha256, `Generated chunk hash drifted: ${relativePath}`);
    const chunk = readJson(relativePath);
    invariant(chunk.schema_version === "ti.godot-world-chunk/2", `Generated chunk schema drifted: ${relativePath}`);
    invariant(chunk.chunk_id === descriptor.chunk_id, `Generated chunk identity drifted: ${relativePath}`);
    for (const record of chunk.records) {
      if (record.receiver_kind !== "building_wall") continue;
      invariant(!receiverByKey.has(record.object_key), `Duplicate generated wall receiver ${record.object_key}`);
      const runCount = validateWallRecord(record, descriptor.chunk_id);
      receiverByKey.set(record.object_key, {
        chunk_id: descriptor.chunk_id,
        chunk_sha256: descriptor.sha256,
        record,
        run_count: runCount,
      });
    }
  }
  invariant(receiverByKey.size === EXPECTED.direct_wall_receivers, `Expected ${EXPECTED.direct_wall_receivers} generated wall receivers, found ${receiverByKey.size}`);
  const visibleRuns = [...receiverByKey.values()].reduce((sum, receiver) => sum + receiver.run_count, 0);
  invariant(visibleRuns === EXPECTED.visible_wall_runs, `Expected ${EXPECTED.visible_wall_runs} visible wall runs, found ${visibleRuns}`);
  return receiverByKey;
}

function validateWallRecord(record, chunkId) {
  invariant(typeof record.object_key === "string" && record.object_key.length > 0, `${chunkId} contains an unnamed receiver`);
  invariant(["building_wall", "building_part_wall"].includes(record.feature_kind), `${record.object_key} has invalid feature kind`);
  invariant(["building_wall", "building_part_wall"].includes(record.material_key), `${record.object_key} has invalid material key`);
  invariant(record.collision_kind === "world_solid" && record.opaque === true, `${record.object_key} lost opaque world-solid semantics`);
  for (const key of ["vertices", "normals", "uvs", "indices", "source_keys"]) {
    invariant(Array.isArray(record[key]), `${record.object_key}.${key} must be an array`);
  }
  invariant(record.source_keys.length === 1, `${record.object_key} must have exactly one direct source key`);
  invariant(record.indices.length > 0 && record.indices.length % 6 === 0, `${record.object_key} run indices are malformed`);
  const runCount = record.indices.length / 6;
  invariant(record.vertices.length === runCount * 12, `${record.object_key} must have four vertices per run`);
  invariant(record.normals.length === record.vertices.length, `${record.object_key} normal count drifted`);
  invariant(record.uvs.length === runCount * 8, `${record.object_key} must have four UVs per run`);
  invariant(
    Number(record.exterior_foundation_segments ?? 0) + Number(record.shared_wall_segments ?? 0) === runCount,
    `${record.object_key} exterior/shared run accounting drifted`,
  );
  for (let run = 0; run < runCount; run += 1) {
    const minimumVertex = run * 4;
    const maximumVertex = minimumVertex + 3;
    const indices = record.indices.slice(run * 6, run * 6 + 6);
    invariant(
      indices.every((index) => Number.isInteger(index) && index >= minimumVertex && index <= maximumVertex),
      `${record.object_key} run ${run} no longer owns one isolated quad`,
    );
    invariant(new Set(indices).size === 4, `${record.object_key} run ${run} does not reference all four quad vertices`);
  }
  return runCount;
}

function inventoryObjectsByKey(inventory) {
  const byKey = new Map();
  for (const object of inventory.objects) {
    const sourceKey = object.source.source_key;
    invariant(!byKey.has(sourceKey), `Duplicate facade inventory source ${sourceKey}`);
    byKey.set(sourceKey, object);
  }
  return byKey;
}

function deriveUnitSeeds(inventory) {
  const byKey = inventoryObjectsByKey(inventory);
  const standalone = inventory.objects.filter(
    (object) => object.footprint_relationship.kind === "standalone_building_footprint",
  );
  const parents = inventory.objects.filter(
    (object) => object.footprint_relationship.kind === "composite_parent_footprint",
  );
  const parts = inventory.objects.filter(
    (object) => object.footprint_relationship.kind === "building_part_within_parent_footprint",
  );
  invariant(standalone.length === EXPECTED.standalone_units, `Expected ${EXPECTED.standalone_units} standalone units, found ${standalone.length}`);
  invariant(parents.length === EXPECTED.composite_units, `Expected one composite parent, found ${parents.length}`);
  invariant(parts.length === EXPECTED.building_parts, `Expected two building parts, found ${parts.length}`);
  invariant(parents[0].source.source_key === ISLE_HOUSE_PARENT, "Unexpected composite parent source");
  invariant(equalStable(parents[0].footprint_relationship.part_source_keys, ISLE_HOUSE_PARTS), "Isle House part membership drifted");

  const units = standalone.map((object) => unitSeed(
    object,
    [object],
    "standalone_building",
  ));
  const parent = parents[0];
  const partObjects = ISLE_HOUSE_PARTS.map((sourceKey) => {
    const part = byKey.get(sourceKey);
    invariant(part != null && part.footprint_relationship.parent_source_key === ISLE_HOUSE_PARENT, `Missing Isle House part ${sourceKey}`);
    return part;
  });
  units.push(unitSeed(parent, [parent, ...partObjects], "composite_building"));
  units.sort((left, right) => compareSourceKeys(left.anchor_source_key, right.anchor_source_key));

  invariant(units.length === EXPECTED.recognition_units, `Expected ${EXPECTED.recognition_units} recognition units, found ${units.length}`);
  const sourceMembership = units.flatMap((unit) => unit.source_records.map((source) => source.source_key));
  const receiverMembership = units.flatMap((unit) => unit.receiver_keys);
  assertUnique(sourceMembership, "Recognition-unit source membership");
  assertUnique(receiverMembership, "Recognition-unit receiver membership");
  invariant(sourceMembership.length === EXPECTED.source_records, `Recognition units cover ${sourceMembership.length} source records instead of ${EXPECTED.source_records}`);
  invariant(receiverMembership.length === EXPECTED.direct_wall_receivers, `Recognition units cover ${receiverMembership.length} receivers instead of ${EXPECTED.direct_wall_receivers}`);
  invariant(
    equalStable([...sourceMembership].sort(compareSourceKeys), [...byKey.keys()].sort(compareSourceKeys)),
    "Recognition units do not partition all inventory source records",
  );
  return units;
}

function unitSeed(anchor, memberObjects, unitKind) {
  const receiverKeys = memberObjects.flatMap(
    (object) => object.generated_receiver.direct_wall_object_keys,
  ).sort();
  const identity = identityFor(anchor);
  const requiresIdentityOrReference = !identity.name_evidence && !identity.address_evidence;
  return {
    acceptance_records: [],
    anchor_source_key: anchor.source.source_key,
    claim_status: {
      as_built_fidelity: "unclaimed",
      game_distinctive: "not_evaluated",
      receiver_complete: "verified",
      reference_recognizable: "not_evaluated",
    },
    human_dependency_ids: [],
    identity,
    legacy_adapter_ids: [],
    protected_scopes: [],
    receiver_keys: receiverKeys,
    recognition_cues: [],
    reference_records: [],
    reference_state: requiresIdentityOrReference
      ? "identity_or_reference_research_required"
      : "reference_research_unassessed",
    source_records: normalizedSourceRecords(memberObjects),
    unit_id: unitId(anchor.source.source_key),
    unit_kind: unitKind,
  };
}

function deriveLegacyAdapterSeeds(inventory) {
  const inventoryAttachments = inventory.runtime_material_contract.accepted_target_specific_runtime_attachments;
  invariant(inventory.runtime_material_contract.accepted_target_specific_runtime_attachment_count === inventoryAttachments.length, "Inventory accepted runtime count disagrees with its attachment list");
  const activeReceiverKeys = new Set([BUILDING_1_WALL, BUILDING_3_WALL, NAVY_CHAPEL_WALL]);
  const attachments = inventoryAttachments.filter((attachment) => !activeReceiverKeys.has(attachment.receiver_key));
  invariant(Array.isArray(attachments), "Inventory accepted runtime attachments are missing");
  invariant(attachments.length === EXPECTED.legacy_adapter_receivers, `Expected ${EXPECTED.legacy_adapter_receivers} accepted legacy receivers, found ${attachments.length}`);
  const seeds = attachments.map((attachment) => ({
    adapter_id: adapterId(attachment.receiver_key),
    import_basis: "inventory_accepted_target_specific_runtime_attachment",
    receiver_key: attachment.receiver_key,
    source_key: attachment.source_key,
    whole_building_recognizability_imported: false,
  })).sort((left, right) => left.receiver_key.localeCompare(right.receiver_key));
  assertUnique(seeds.map((seed) => seed.receiver_key), "Legacy adapter receiver keys");
  return seeds;
}

function gdscriptWithoutComments(source) {
  let result = "";
  let quote = null;
  let escaped = false;
  let comment = false;
  for (const character of source) {
    if (comment) {
      if (character === "\n") {
        comment = false;
        result += character;
      }
      continue;
    }
    if (quote != null) {
      result += character;
      if (escaped) {
        escaped = false;
      } else if (character === "\\") {
        escaped = true;
      } else if (character === quote) {
        quote = null;
      }
      continue;
    }
    if (character === "#") {
      comment = true;
      continue;
    }
    result += character;
    if (character === "\"" || character === "'") quote = character;
  }
  return result;
}

function occurrenceCount(source, marker) {
  let count = 0;
  let offset = 0;
  while (true) {
    const index = source.indexOf(marker, offset);
    if (index < 0) return count;
    count += 1;
    offset = index + marker.length;
  }
}

function exactWorldBuilderMarkerIndex(builderText, marker, label) {
  const count = occurrenceCount(builderText, marker);
  invariant(count === 1, `Current world-builder ${label} marker must occur exactly once; found ${count}`);
  return builderText.indexOf(marker);
}

function validateCurrentWorldBuilderDispatch(inputs) {
  const contract = inputs.runtimeContracts;
  invariant(contract.acceptedWorldBuilderSha256 === D2_1441_REVIEWED_WORLD_BUILDER_SHA256, "Accepted world-builder provenance no longer names the independently reviewed D2 1441 production closure");
  invariant(contract.currentWorldBuilderSha256 === sha256Bytes(contract.worldBuilderText), "Current world-builder text/hash binding drifted");
  const builderText = gdscriptWithoutComments(contract.worldBuilderText);
  const markers = {
    generic_vertices: "var vertices := PackedVector3Array()",
    generic_body: "var body := StaticBody3D.new()",
    building_1_preload: `const BUILDING_1_HERO_MODEL := preload("res://${BUILDING_1_HERO_ADAPTER_PATH}")`,
    building_1_claim: "if not is_context and BUILDING_1_HERO_MODEL.matches_record(record):",
    building_1_build: "return BUILDING_1_HERO_MODEL.build_record(record)",
    building_3_preload: `const BUILDING_3_MASSING := preload("res://${BUILDING_3_MASSING_PATH}")`,
    building_3_claim: "if not is_context and BUILDING_3_MASSING.matches_record(record):",
    building_3_build: "return BUILDING_3_MASSING.build_record(",
    isle_house_preload: `const ISLE_HOUSE_LOW_LIVE_ATTACHMENT := preload("res://${ISLE_HOUSE_LIVE_ADAPTER_PATH}")`,
    isle_house_claim: "if not is_context and ISLE_HOUSE_LOW_LIVE_ATTACHMENT.matches_record(record):",
    isle_house_build: "var isle_house_low_result := ISLE_HOUSE_LOW_LIVE_ATTACHMENT.build(record)",
    navy_chapel_preload: `const NAVY_CHAPEL_187_LIVE_REPLACEMENT := preload("res://${NAVY_CHAPEL_LIVE_ADAPTER_PATH}")`,
    navy_chapel_prepare: "NAVY_CHAPEL_187_LIVE_REPLACEMENT.prepare_chunk_records(chunk.records as Array)",
    navy_chapel_plan: "NAVY_CHAPEL_187_LIVE_REPLACEMENT.build_chunk_plan(chapel_pair)",
    navy_chapel_record_dispatch: "var record_result := _build_record(record, false, chapel_plan, d2_1441_plan, d2_1439_plan, d2_1444_plan, d5_1308_plan, d5_1394_plan, d5_1317_plan, fs48_plan)",
    navy_chapel_claim: "if not is_context and NAVY_CHAPEL_187_LIVE_REPLACEMENT.claims_record(record):",
    navy_chapel_consume: "return NAVY_CHAPEL_187_LIVE_REPLACEMENT.consume_record(record, chapel_plan)",
    navy_chapel_consumed: "NAVY_CHAPEL_187_LIVE_REPLACEMENT.plan_was_fully_consumed(chapel_plan)",
    d2_1441_preload: `const D2_1441_CHINOOK_LIVE_REPLACEMENT := preload("res://${D2_1441_LIVE_ADAPTER_PATH}")`,
    d2_1441_prepare: "D2_1441_CHINOOK_LIVE_REPLACEMENT.prepare_chunk_records(chunk)",
    d2_1441_plan: "D2_1441_CHINOOK_LIVE_REPLACEMENT.build_chunk_plan(d2_1441_pair)",
    d2_1441_record_dispatch: "var record_result := _build_record(record, false, chapel_plan, d2_1441_plan, d2_1439_plan, d2_1444_plan, d5_1308_plan, d5_1394_plan, d5_1317_plan, fs48_plan)",
    d2_1441_claim: "if not is_context and D2_1441_CHINOOK_LIVE_REPLACEMENT.claims_record(record):",
    d2_1441_consume: "return D2_1441_CHINOOK_LIVE_REPLACEMENT.consume_record(record, d2_1441_plan)",
    d2_1441_consumed: "D2_1441_CHINOOK_LIVE_REPLACEMENT.plan_was_fully_consumed(d2_1441_plan)",
    d2_1439_preload: `const D2_1439_CHINOOK_LIVE_REPLACEMENT := preload("res://${D2_1439_LIVE_ADAPTER_PATH}")`,
    d2_1439_prepare: "D2_1439_CHINOOK_LIVE_REPLACEMENT.prepare_chunk_records(chunk)",
    d2_1439_plan: "D2_1439_CHINOOK_LIVE_REPLACEMENT.build_chunk_plan(d2_1439_pair)",
    d2_1439_record_dispatch: "var record_result := _build_record(record, false, chapel_plan, d2_1441_plan, d2_1439_plan, d2_1444_plan, d5_1308_plan, d5_1394_plan, d5_1317_plan, fs48_plan)",
    d2_1439_claim: "if not is_context and D2_1439_CHINOOK_LIVE_REPLACEMENT.claims_record(record):",
    d2_1439_consume: "return D2_1439_CHINOOK_LIVE_REPLACEMENT.consume_record(record, d2_1439_plan)",
    d2_1439_consumed: "D2_1439_CHINOOK_LIVE_REPLACEMENT.plan_was_fully_consumed(d2_1439_plan)",
    d2_1444_preload: `const D2_1444_CROAKER_LIVE_REPLACEMENT := preload("res://${D2_1444_LIVE_ADAPTER_PATH}")`,
    d2_1444_prepare: "D2_1444_CROAKER_LIVE_REPLACEMENT.prepare_chunk_records(chunk)",
    d2_1444_plan: "D2_1444_CROAKER_LIVE_REPLACEMENT.build_chunk_plan(d2_1444_pair)",
    d2_1444_record_dispatch: "var record_result := _build_record(record, false, chapel_plan, d2_1441_plan, d2_1439_plan, d2_1444_plan, d5_1308_plan, d5_1394_plan, d5_1317_plan, fs48_plan)",
    d2_1444_claim: "if not is_context and D2_1444_CROAKER_LIVE_REPLACEMENT.claims_record(record):",
    d2_1444_consume: "return D2_1444_CROAKER_LIVE_REPLACEMENT.consume_record(record, d2_1444_plan)",
    d2_1444_consumed: "D2_1444_CROAKER_LIVE_REPLACEMENT.plan_was_fully_consumed(d2_1444_plan)",
    d1_b201_preload: `const D1_B201_LIVE_ATTACHMENT := preload("res://${D1_B201_LIVE_ADAPTER_PATH}")`,
    d1_b201_validate: "D1_B201_LIVE_ATTACHMENT.validate_chunk_records(chunk)",
    d1_b201_claim: "if not is_context and D1_B201_LIVE_ATTACHMENT.claims_record(record):",
    d1_b201_prepare: "D1_B201_LIVE_ATTACHMENT.prepare(record)",
    d1_b201_host_uvs: "D1_B201_LIVE_ATTACHMENT.host_uvs(record, b201_prepared)",
    d1_b201_partition: "D1_B201_LIVE_ATTACHMENT.partition_host(record, indices, placeholder_material, b201_prepared)",
    d1_b201_build: "D1_B201_LIVE_ATTACHMENT.build_prepared(record, b201_prepared)",
    d1_b225_preload: `const D1_B225_LIVE_ATTACHMENT := preload("res://${D1_B225_LIVE_ADAPTER_PATH}")`,
    d1_b225_validate: "D1_B225_LIVE_ATTACHMENT.validate_chunk_records(chunk)",
    d1_b225_claim: "if not is_context and D1_B225_LIVE_ATTACHMENT.claims_record(record):",
    d1_b225_prepare: "D1_B225_LIVE_ATTACHMENT.prepare(record)",
    d1_b225_host_uvs: "D1_B225_LIVE_ATTACHMENT.host_uvs(record, b225_prepared)",
    d1_b225_partition: "D1_B225_LIVE_ATTACHMENT.partition_host(record, indices, placeholder_material, b225_prepared)",
    d1_b225_build: "D1_B225_LIVE_ATTACHMENT.build_prepared(record, b225_prepared)",
  };
  markers.d5_1308_prepare = "D5_1308_GATEVIEW_LIVE_REPLACEMENT.prepare_chunk_records(chunk)";
  markers.d5_1308_plan = "D5_1308_GATEVIEW_LIVE_REPLACEMENT.build_chunk_plan(d5_1308_pair,";
  markers.d5_1308_claim = "if not is_context and D5_1308_GATEVIEW_LIVE_REPLACEMENT.claims_record(record):";
  markers.d5_1308_consume = "return D5_1308_GATEVIEW_LIVE_REPLACEMENT.consume_record(record, d5_1308_plan)";
  markers.d5_1308_consumed = "D5_1308_GATEVIEW_LIVE_REPLACEMENT.plan_was_fully_consumed(d5_1308_plan)";
  markers.d5_1394_prepare = "D5_1394_GATEVIEW_LIVE_REPLACEMENT.prepare_chunk_records(chunk)";
  markers.d5_1317_prepare = "D5_1317_GATEVIEW_LIVE_REPLACEMENT.prepare_chunk_records(chunk)";
  markers.fire_station48_prepare = "FIRE_STATION48_LIVE_REPLACEMENT.prepare_chunk_records(chunk)";
  markers.d5_1394_plan = "D5_1394_GATEVIEW_LIVE_REPLACEMENT.build_chunk_plan(d5_1394_pair,";
  markers.d5_1317_plan = "D5_1317_GATEVIEW_LIVE_REPLACEMENT.build_chunk_plan(d5_1317_pair,";
  markers.fire_station48_plan = "FIRE_STATION48_LIVE_REPLACEMENT.build_chunk_plan(fs48_pair,";
  markers.d5_1394_claim = "if not is_context and D5_1394_GATEVIEW_LIVE_REPLACEMENT.claims_record(record):";
  markers.d5_1317_claim = "if not is_context and D5_1317_GATEVIEW_LIVE_REPLACEMENT.claims_record(record):";
  markers.fire_station48_claim = "if not is_context and FIRE_STATION48_LIVE_REPLACEMENT.claims_record(record):";
  markers.d5_1394_consume = "return D5_1394_GATEVIEW_LIVE_REPLACEMENT.consume_record(record, d5_1394_plan)";
  markers.d5_1317_consume = "return D5_1317_GATEVIEW_LIVE_REPLACEMENT.consume_record(record, d5_1317_plan)";
  markers.fire_station48_consume = "return FIRE_STATION48_LIVE_REPLACEMENT.consume_record(record, fs48_plan)";
  markers.d5_1394_consumed = "D5_1394_GATEVIEW_LIVE_REPLACEMENT.plan_was_fully_consumed(d5_1394_plan)";
  markers.d5_1317_consumed = "D5_1317_GATEVIEW_LIVE_REPLACEMENT.plan_was_fully_consumed(d5_1317_plan)";
  markers.fire_station48_consumed = "FIRE_STATION48_LIVE_REPLACEMENT.plan_was_fully_consumed(fs48_plan)";
  const positions = {};
  for (const [label, marker] of Object.entries(markers)) {
    positions[label] = exactWorldBuilderMarkerIndex(builderText, marker, label.replaceAll("_", " "));
  }

  const before = (left, right, message) => invariant(positions[left] < positions[right], message);
  before("building_1_claim", "building_1_build", "Building 1 claim must precede its direct build");
  before("building_1_build", "generic_vertices", "Building 1 direct dispatch must precede generic construction");
  before("building_3_claim", "building_3_build", "Building 3 claim must precede its direct build");
  before("building_3_build", "generic_vertices", "Building 3 direct dispatch must precede generic construction");
  before("navy_chapel_prepare", "navy_chapel_plan", "Navy Chapel pair preparation must precede plan construction");
  before("navy_chapel_plan", "navy_chapel_claim", "Navy Chapel plan construction must precede per-record dispatch");
  before("navy_chapel_claim", "navy_chapel_consume", "Navy Chapel paired claim must precede paired consumption");
  before("navy_chapel_consume", "generic_vertices", "Navy Chapel paired consumption must precede generic construction");
  // The consume call lives in _build_record(), whose exact loop dispatch is the
  // executable lifecycle edge in _build_chunk(); source-function order alone
  // cannot express that nested call before the post-loop consumed assertion.
  before("navy_chapel_record_dispatch", "navy_chapel_consumed", "Navy Chapel per-record consumption dispatch must precede the fully-consumed assertion");
  before("d2_1441_prepare", "d2_1441_plan", "D2 1441 pair preparation must precede plan construction");
  before("d2_1439_prepare", "d2_1439_plan", "D2 1439 pair preparation must precede plan construction");
  before("d2_1444_prepare", "d2_1444_plan", "D2 1444 pair preparation must precede plan construction");
  before("d2_1441_plan", "d2_1441_claim", "D2 1441 plan construction must precede per-record dispatch");
  before("d2_1439_plan", "d2_1439_claim", "D2 1439 plan construction must precede per-record dispatch");
  before("d2_1444_plan", "d2_1444_claim", "D2 1444 plan construction must precede per-record dispatch");
  before("d2_1441_claim", "d2_1441_consume", "D2 1441 paired claim must precede paired consumption");
  before("d2_1439_claim", "d2_1439_consume", "D2 1439 paired claim must precede paired consumption");
  before("d2_1444_claim", "d2_1444_consume", "D2 1444 paired claim must precede paired consumption");
  before("d2_1441_consume", "generic_vertices", "D2 1441 paired consumption must precede generic construction");
  before("d2_1439_consume", "generic_vertices", "D2 1439 paired consumption must precede generic construction");
  before("d2_1444_consume", "generic_vertices", "D2 1444 paired consumption must precede generic construction");
  before("d2_1441_record_dispatch", "d2_1441_consumed", "D2 1441 per-record consumption dispatch must precede the fully-consumed assertion");
  before("d2_1439_record_dispatch", "d2_1439_consumed", "D2 1439 per-record consumption dispatch must precede the fully-consumed assertion");
  before("d2_1444_record_dispatch", "d2_1444_consumed", "D2 1444 per-record consumption dispatch must precede the fully-consumed assertion");
  before("d5_1308_prepare", "d5_1308_plan", "D5 1308 atomic lifecycle order drifted");
  before("d5_1308_plan", "d5_1308_claim", "D5 1308 atomic lifecycle order drifted");
  before("d5_1308_claim", "d5_1308_consume", "D5 1308 atomic lifecycle order drifted");
  before("d5_1308_consume", "generic_vertices", "D5 1308 must consume before generic construction");
  before("d2_1444_record_dispatch", "d5_1308_consumed", "D5 1308 consumption must precede its sealed-plan assertion");
  invariant(occurrenceCount(builderText, "D5_1308_GATEVIEW_LIVE_REPLACEMENT.free_unconsumed(d5_1308_plan)") === 6, "D5 1308 rollback lifecycle drifted");
  before("d5_1394_prepare", "d5_1394_plan", "D5 1394 atomic lifecycle order drifted");
  before("d5_1317_prepare", "d5_1317_plan", "D5 1317 atomic lifecycle order drifted");
  before("fire_station48_prepare", "fire_station48_plan", "Station48 atomic lifecycle order drifted");
  before("d5_1394_plan", "d5_1394_claim", "D5 1394 atomic lifecycle order drifted");
  before("d5_1317_plan", "d5_1317_claim", "D5 1317 atomic lifecycle order drifted");
  before("fire_station48_plan", "fire_station48_claim", "Station48 atomic lifecycle order drifted");
  before("d5_1394_claim", "d5_1394_consume", "D5 1394 atomic lifecycle order drifted");
  before("d5_1317_claim", "d5_1317_consume", "D5 1317 atomic lifecycle order drifted");
  before("fire_station48_claim", "fire_station48_consume", "Station48 atomic lifecycle order drifted");
  before("d5_1394_consume", "generic_vertices", "D5 1394 must consume before generic construction");
  before("d5_1317_consume", "generic_vertices", "D5 1317 must consume before generic construction");
  before("fire_station48_consume", "generic_vertices", "Station48 must consume before generic construction");
  before("d2_1444_record_dispatch", "d5_1394_consumed", "D5 1394 consumption must precede its sealed-plan assertion");
  before("d2_1444_record_dispatch", "d5_1317_consumed", "D5 1317 consumption must precede its sealed-plan assertion");
  before("d2_1444_record_dispatch", "fire_station48_consumed", "Station48 consumption must precede its sealed-plan assertion");
  invariant(occurrenceCount(builderText, "D5_1394_GATEVIEW_LIVE_REPLACEMENT.free_unconsumed(d5_1394_plan)") === 5, "D5 1394 rollback lifecycle drifted");
  invariant(occurrenceCount(builderText, "D5_1317_GATEVIEW_LIVE_REPLACEMENT.free_unconsumed(d5_1317_plan)") === 4, "D5 1317 rollback lifecycle drifted");
  invariant(occurrenceCount(builderText, "FIRE_STATION48_LIVE_REPLACEMENT.free_unconsumed(fs48_plan)") === 3, "Station48 rollback lifecycle drifted");
  before("d1_b201_validate", "d1_b201_claim", "D1 B201 chunk validation must precede its per-record claim");
  before("d1_b201_claim", "d1_b201_prepare", "D1 B201 claim must precede preparation");
  before("d1_b201_prepare", "generic_vertices", "D1 B201 preparation must precede generic construction");
  before("generic_vertices", "d1_b201_host_uvs", "D1 B201 host UV dispatch must follow generic vertex construction");
  before("d1_b201_host_uvs", "d1_b201_partition", "D1 B201 host UV dispatch must precede host partitioning");
  before("d1_b201_partition", "generic_body", "D1 B201 host partition must precede generic body construction");
  before("generic_body", "d1_b201_build", "D1 B201 build_prepared must follow retained generic body construction");
  before("d1_b225_validate", "d1_b225_claim", "D1 B225 chunk validation must precede its per-record claim");
  before("d1_b225_claim", "d1_b225_prepare", "D1 B225 claim must precede preparation");
  before("d1_b225_prepare", "generic_vertices", "D1 B225 preparation must precede generic construction");
  before("generic_vertices", "d1_b225_host_uvs", "D1 B225 host UV dispatch must follow generic vertex construction");
  before("d1_b225_host_uvs", "d1_b225_partition", "D1 B225 host UV dispatch must precede host partitioning");
  before("d1_b225_partition", "generic_body", "D1 B225 host partition must precede generic body construction");
  before("generic_body", "d1_b225_build", "D1 B225 build_prepared must follow retained generic body construction");
  before("generic_body", "isle_house_claim", "Isle House low attachment must follow retained generic body construction");
  before("isle_house_claim", "isle_house_build", "Isle House low claim must precede its attachment build");

  invariant(sha256File(absolute(WORLD_CHUNK_BUILDER_PATH)) === D5_BATCH_BUILDER_SHA256, "Current batch dispatch bytes drifted");
  invariant(occurrenceCount(builderText, "D2_1439_CHINOOK_LIVE_REPLACEMENT.free_unconsumed(d2_1439_plan)") === 8, "Current 1439 cleanup lifecycle drifted");
  invariant(occurrenceCount(builderText, "D2_1444_CROAKER_LIVE_REPLACEMENT.free_unconsumed(d2_1444_plan)") === 7, "Current 1444 cleanup lifecycle drifted");
  const currentDependencies = runtimeDependencies(builderText);
  invariant(occurrenceCount(builderText, "D2_1441_CHINOOK_LIVE_REPLACEMENT.free_unconsumed(d2_1441_plan)") === 9, "Current world-builder D2 1441 cleanup marker must occur exactly five times");
  for (const dependency of D2_1441_REVIEWED_WORLD_BUILDER_DEPENDENCY_PATHS) {
    invariant(currentDependencies.includes(dependency), `Current world builder lost accepted D2 1441 package dependency ${dependency}`);
  }

  const forbidden = [
    ["generic facade registry loader", /facade_runtime_registry_loader/iu],
    ["runtime resource load", /(?:^|[^A-Za-z0-9_])(?:ResourceLoader\s*\.\s*)?load(?:_threaded_request|_threaded_get)?\s*\(/u],
    ["ProjectSettings dispatch", /\bProjectSettings\b/u],
    ["environment-controlled dispatch", /\bOS\s*\.\s*get_environment\s*\(/u],
    ["command-line-controlled dispatch", /\bOS\s*\.\s*get_cmdline(?:_user_args)?\s*\(/u],
    ["feature-flag-controlled dispatch", /(?:\bOS\s*\.\s*has_feature\s*\(|\bfeature_flags?\b)/iu],
    ["feature-flag-controlled dispatch", /\b(?:ENABLE|FEATURE)_[A-Z0-9_]+\b/u],
    ["fallback or alternate dispatch", /(?:fallback|alternate)[_A-Za-z0-9]*(?:dispatch|adapter)|(?:dispatch|adapter)[_A-Za-z0-9]*(?:fallback|alternate)/iu],
    ["obsolete Building 1 dispatch", /building_1_recognizable_facade\.gd/u],
  ];
  for (const [label, pattern] of forbidden) {
    invariant(!pattern.test(builderText), `Current world builder contains forbidden ${label}`);
  }
  for (const match of builderText.matchAll(/\bpreload\s*\(([^)\n]*)\)/gu)) {
    const argument = match[1].trim();
    invariant(/^(?:"res:\/\/[^"\n]+"|'res:\/\/[^'\n]+')$/u.test(argument), "Current world builder contains forbidden preload-by-runtime-string dispatch");
  }
}

function validateBuilding1ReturnsAcceptance(contract) {
  const receipt = contract.heroReturnsAcceptance;
  invariant(contract.heroReturnsAcceptanceSha256 === B1_RETURNS_ACCEPTANCE_SHA256 &&
    sha256Bytes(stableJson(receipt)) === B1_RETURNS_ACCEPTANCE_CANONICAL_SHA256,
  "Building 1 returns v2 exact source-only acceptance receipt drifted");
  invariant(receipt.schema_version === "ti.building-1-wing-returns-v2-acceptance/1" &&
    receipt.recognition_credit_delta === 0 && receipt.recognition_metric === "9/213" &&
    receipt.proof_boundaries.full_current_release_pass === false &&
    receipt.proof_boundaries.source_renders_are_package_pixels === false,
  "Building 1 returns v2 quality/recognition/release boundary drifted");
  invariant(contract.heroPublicFrontConfigSha256 === "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb" &&
    sha256Bytes(stableJson(contract.heroPublicFrontConfig)) === "d89280e1f12052ccb6318cc5ccaa7609ed02677facdbd37b12b2b2febe9e42cc" &&
    contract.heroAdapterSha256 === "ce2f21dab02163b5f45d9d7e457f5d0ce96089bc55cca6e65aa9924c9f199c5a" &&
    sha256Bytes(contract.heroAdapterText) === contract.heroAdapterSha256,
  "Building 1 returns v2 accepted executable source drifted");
  for (const file of receipt.source_inputs) {
    invariant(sha256File(absolute(file.path)) === file.sha256 && statSync(absolute(file.path)).size === file.bytes,
      `Building 1 returns v2 frozen source input drifted: ${file.path}`);
  }
  for (const review of receipt.reviews) {
    invariant(sha256File(absolute(review.path)) === review.sha256 &&
      readFileSync(absolute(review.path), "utf8").includes(review.token),
    `Building 1 returns v2 independent ${review.role} review drifted`);
  }
  const evidence = receipt.candidate_verification;
  const files = evidence.input_inventory;
  invariant(files.length === 98 && evidence.original_pngs === 92 && evidence.manifests === 6,
    "Building 1 returns v2 accepted evidence count drifted");
  assertUnique(files.map((file) => file.path), "Building 1 returns v2 evidence paths");
  for (const file of [...files, { path: evidence.path, sha256: evidence.sha256 }]) {
    invariant(!file.path.includes("..") && !file.path.startsWith("/"), "Building 1 returns v2 evidence path escapes packet");
    const path = absolute(`${B1_RETURNS_ACCEPTANCE_ROOT}/${file.path}`);
    invariant(sha256File(path) === file.sha256 && (file.bytes == null || statSync(path).size === file.bytes),
      `Building 1 returns v2 accepted evidence bytes drifted: ${file.path}`);
  }
  const ordered = [...files].sort((a, b) => a.path < b.path ? -1 : a.path > b.path ? 1 : 0);
  invariant(sha256Bytes(ordered.map((file) => `${file.path}|${file.sha256}|${file.bytes}\n`).join("")) === evidence.input_tree_sha256 &&
    files.reduce((total, file) => total + file.bytes, 0) === evidence.input_total_bytes,
  "Building 1 returns v2 evidence tree identity drifted");
}

function validateActiveHeroDispatch(inputs) {
  const contract = inputs.runtimeContracts;
  const config = contract.heroConfig;
  const target = config.target ?? {};
  const authority = config.authority ?? {};
  const publicFront = contract.heroPublicFrontConfig;
  const publicFrontAuthority = publicFront.authority ?? {};
  const provenance = contract.packageSanitizationSourceProvenance;
  const provenanceRecords = provenance.records ?? {};
  const heroProvenance = provenanceRecords["B1-HERO-AUTHORITY"] ?? {};
  const publicFrontProvenance = provenanceRecords["B1-PUBLIC-FRONT-AUTHORITY"] ?? {};
  invariant(config.schema_version === "ti.building-1-hero-model/1", "Building 1 hero config schema drifted");
  invariant(target.building_source_key === BUILDING_1_SOURCE && target.building_wall_key === BUILDING_1_WALL, "Building 1 hero config main-building target drifted");
  invariant(target.tower_source_key === BUILDING_1_TOWER_SOURCE && target.tower_wall_key === BUILDING_1_TOWER_WALL, "Building 1 hero config tower target drifted");
  invariant(target.tower_remains_separately_reviewable === true, "Building 1 hero config collapses the tower into the main physical unit");
  invariant(typeof config.truth_boundary?.visual_review_status === "string" && config.truth_boundary.visual_review_status.length > 0, "Building 1 hero config lacks an explicit visual-review status");
  invariant(contract.packageSanitizationSourceProvenanceSha256 === PACKAGE_SANITIZATION_SOURCE_PROVENANCE_SHA256, "Package-sanitization source provenance receipt drifted");
  invariant(provenance.schema_version === "ti.precommit-package-sanitization-source-provenance/1" && provenance.scope.includes("excluded from the canonical game package"), "Package-sanitization source provenance boundary drifted");
  invariant(heroProvenance.historical_runtime_config_sha256 === "6c99f43550631a1e6bca1f52764ad23c6a5b8b891403f30c78ff9b9545192690", "Building 1 historical config receipt drifted");
  invariant(heroProvenance.primary_nps_nomination === "https://npgallery.nps.gov/NRHP/GetAsset/NRHP/08000081_text" && heroProvenance.museum_building_page.startsWith("https://www.treasureislandmuseum.org/") && heroProvenance.museum_sculpture_page.startsWith("https://www.treasureislandmuseum.org/"), "Building 1 source-only authority locators drifted");
  invariant(authority.source_provenance_receipt_id === "B1-HERO-AUTHORITY" && authority.source_provenance_receipt_sha256 === PACKAGE_SANITIZATION_SOURCE_PROVENANCE_SHA256 && authority.primary_nps_record_id === "NRHP-08000081" && authority.primary_nps_sections === heroProvenance.primary_nps_sections, "Building 1 package-safe authority receipt drifted");
  invariant(equalStable(authority.museum_reference_ids, ["TIM-BUILDING-THE-BAY-BRIDGE-AND-TREASURE-ISLAND", "TIM-SCULPTURES-AND-ISLAND"]), "Building 1 package-safe museum authority IDs drifted");
  invariant(publicFront.schema_version === "ti.building-1-public-front-believability/3", "Building 1 public-front config schema drifted");
  validateBuilding1ReturnsAcceptance(contract);
  invariant(publicFront.geometry_production_inference_m?.entrance_group_gap === 0.90, "Building 1 public-front entrance-group gap is not the reviewed 0.90 m candidate");
  invariant(publicFrontProvenance.historical_runtime_config_sha256 === "e11710374f837e15b45adf3b6df0e762a6793b363e6c3109870e1bf2f7a0ee0e", "Building 1 public-front historical config receipt drifted");
  invariant(publicFrontAuthority.source_provenance_receipt_id === "B1-PUBLIC-FRONT-AUTHORITY" && publicFrontAuthority.source_provenance_receipt_sha256 === PACKAGE_SANITIZATION_SOURCE_PROVENANCE_SHA256, "Building 1 public-front source receipt drifted");
  invariant(publicFrontAuthority.bar_raiser_review_sha256 === publicFrontProvenance.bar_raiser_review?.sha256 && publicFrontAuthority.hero_spec_sha256 === publicFrontProvenance.hero_spec?.sha256, "Building 1 public-front package-safe receipt hashes drifted");
  invariant(forbiddenAssetKinds(stableJson(config)).length === 0 && forbiddenAssetKinds(stableJson(publicFront)).length === 0, "Building 1 executable configs retain source-only paths or URLs");
  const heroText = contract.heroAdapterText;
  for (const expected of [
    `const CONFIG_PATH := "res://${BUILDING_1_HERO_CONFIG_PATH}"`,
    `const BUILDING_SOURCE_KEY := "${BUILDING_1_SOURCE}"`,
    `const BUILDING_WALL_KEY := "${BUILDING_1_WALL}"`,
    `const TOWER_SOURCE_KEY := "${BUILDING_1_TOWER_SOURCE}"`,
    `const TOWER_WALL_KEY := "${BUILDING_1_TOWER_WALL}"`,
    "const TARGET_KEYS := [BUILDING_WALL_KEY, BUILDING_ROOF_KEY, TOWER_WALL_KEY, TOWER_ROOF_KEY]",
  ]) invariant(heroText.includes(expected), `Building 1 hero adapter contract drifted: ${expected}`);
}

function building1HeroMaterialPaths(inputs) {
  const matches = inputs.runtimeContracts.heroAdapterText.matchAll(/preload\("res:\/\/(game\/resources\/materials\/world\/building_1\/[^"\n]+)"\)/gu);
  const paths = [...matches].map((match) => match[1]).sort();
  assertUnique(paths, "Building 1 hero material paths");
  invariant(paths.length === 8, `Expected eight exact-current Building 1 hero material assets, found ${paths.length}`);
  return paths;
}

function validateActiveBuilding3Dispatch(inputs) {
  const contract = inputs.runtimeContracts;
  const config = contract.building3Config;
  const target = config.target ?? {};
  const identity = config.authoritative_identity ?? {};
  const truth = config.truth_boundary ?? {};
  invariant(config.schema_version === "ti.building-3-hero-massing/1", "Building 3 hero config schema drifted");
  invariant(target.source_key === BUILDING_3_SOURCE && target.wall_object_key === BUILDING_3_WALL && target.roof_object_key === BUILDING_3_ROOF, "Building 3 hero config wall/roof target drifted");
  invariant(identity.nrhp_id === "08000083" && identity.frozen_osm_nrhp_ref === "08000081", "Building 3 hero config identity correction/provenance drifted");
  invariant(!Object.hasOwn(identity, "nps_asset_url") && !/https?:\/\//u.test(stableJson(config)), "Building 3 executable config still contains source-only URL provenance");
  const provenance = structuredClone(contract.building3AuthoringProvenance);
  const provenanceIdentity = provenance.authoritative_identity ?? {};
  invariant(contract.building3AuthoringProvenanceSha256 === BUILDING_3_AUTHORING_PROVENANCE_SHA256, "Building 3 source-bearing capture provenance snapshot drifted");
  invariant(provenanceIdentity.nps_asset_url === "https://npgallery.nps.gov/AssetDetail/NRIS/08000083", "Building 3 source-only NPS locator drifted");
  delete provenanceIdentity.nps_asset_url;
  invariant(equalStable(provenance, config), "Building 3 package-safe config is not behavior-equivalent to its source-bearing authoring snapshot");
  invariant(truth.horizontal_source_footprint_preserved === true && truth.generated_bytes_unchanged === true && truth.exterior_only === true && truth.interior_modeled === false && truth.as_built_fidelity_claimed === false, "Building 3 hero truth boundary drifted");
  const massingText = contract.building3MassingText;
  for (const expected of [
    `const TARGET_SOURCE_KEY := "${BUILDING_3_SOURCE}"`,
    `const TARGET_WALL_KEY := "${BUILDING_3_WALL}"`,
    `const TARGET_ROOF_KEY := "${BUILDING_3_ROOF}"`,
    `const CONFIG_PATH := "res://${BUILDING_3_CONFIG_PATH}"`,
    'const FACADE_SCENE := preload("res://game/scenes/world/facades/building_3/building_3_600_california_facade.tscn")',
    'root.set_meta("runtime_supersedes_generated_placeholder", true)',
    'body.collision_layer = PHYSICS_WORLD_SOLID | (PHYSICS_SPRAY_SURFACE if object_key == TARGET_WALL_KEY else 0)',
    'body.add_to_group("spray_receiver_wall")',
    'if object_key == TARGET_WALL_KEY:',
  ]) invariant(massingText.includes(expected), `Building 3 massing behavior contract drifted: ${expected}`);
  for (const path of BUILDING_3_FACADE_ASSET_PATHS) {
    invariant(existsSync(absolute(path)) && statSync(absolute(path)).isFile(), `Building 3 current facade asset is missing: ${path}`);
  }
}

function validateActiveIsleHouseDispatch(inputs) {
  const contract = inputs.runtimeContracts;
  const config = contract.isleHouseConfig;
  const target = config.target ?? {};
  const truth = config.truth_boundary ?? {};
  invariant(config.schema_version === "ti.isle-house-composite-repair-variant-c-standalone/1", "Isle House Variant C config schema drifted");
  invariant(target.parent_source_key === ISLE_HOUSE_PARENT, "Isle House Variant C parent identity drifted");
  invariant(target.high_wall_key === ISLE_HOUSE_HIGH_WALL && target.low_wall_key === ISLE_HOUSE_LOW_WALL, "Isle House Variant C high/low receiver identities drifted");
  invariant(target.high_source_key === ISLE_HOUSE_PARTS[0] && target.low_source_key === ISLE_HOUSE_LOW_SOURCE, "Isle House Variant C high/low source identities drifted");
  invariant(truth.as_built_fidelity === false && truth.source_pixels_packaged === false && truth.upper_schedule_claimed === false && truth.literal_seven_story_geometry_claimed === false && truth.protected_return_opening_schedule_claimed === false, "Isle House Variant C truth boundary drifted");
  const adapterText = contract.isleHouseLiveAdapterText;
  for (const expected of [
    `const LIVE_TARGET_RECEIVER_OBJECT_KEY := "${ISLE_HOUSE_LOW_WALL}"`,
    `const LIVE_TARGET_SOURCE_KEY := "${ISLE_HOUSE_LOW_SOURCE}"`,
    `const EXPECTED_REPAIR_SIGNATURE := "${ISLE_HOUSE_REPAIR_SIGNATURE}"`,
    `const EXPECTED_LIVE_SIGNATURE := "${ISLE_HOUSE_LIVE_SIGNATURE}"`,
    'node.set_meta("rejected_overlay_fallback_used", false)',
    'node.set_meta("overlay_stacked", false)',
    'node.set_meta("spray_ray_owner", "unchanged_underlying_receiver")',
  ]) invariant(adapterText.includes(expected), `Isle House Variant C live adapter contract drifted: ${expected}`);
  for (const path of [ISLE_HOUSE_LIVE_ADAPTER_PATH, ISLE_HOUSE_REPAIR_FACTORY_PATH, ISLE_HOUSE_REVIEWED_FACTORY_PATH, ISLE_HOUSE_VARIANT_C_CONFIG_PATH]) {
    invariant(existsSync(absolute(path)) && statSync(absolute(path)).isFile(), `Isle House current runtime asset is missing: ${path}`);
  }
}

function validateActiveNavyChapelDispatch(inputs) {
  const contract = inputs.runtimeContracts;
  const config = contract.navyChapelConfig;
  const target = config.target ?? {};
  const truth = config.truth_boundary ?? {};
  invariant(config.schema_version === "ti.navy-chapel-187-standalone-hero-prototype/1", "Navy Chapel source-model config schema drifted");
  invariant(target.source_key === NAVY_CHAPEL_SOURCE && target.wall_object_key === NAVY_CHAPEL_WALL && target.roof_object_key === NAVY_CHAPEL_ROOF, "Navy Chapel wall/roof target drifted");
  invariant(target.wall_run_count === 34 && target.wall_triangles === 68 && target.roof_triangles === 18, "Navy Chapel frozen source topology drifted");
  invariant(truth.horizontal_source_footprint_changed === false && truth.source_identity_changed === false && truth.as_built_claim === false, "Navy Chapel source/truth boundary drifted");
  const adapterText = contract.navyChapelLiveAdapterText;
  for (const expected of [
    `const SOURCE_KEY := "${NAVY_CHAPEL_SOURCE}"`,
    `const WALL_KEY := "${NAVY_CHAPEL_WALL}"`,
    `const ROOF_KEY := "${NAVY_CHAPEL_ROOF}"`,
    'const CANONICAL_WALL_RECORD_SHA256 := "69769fef402b480f1626fdce47e6d4ad49ecb710dab2b2e7373e5efa5acf0080"',
    'const CANONICAL_ROOF_RECORD_SHA256 := "54bcd378997d0778bdaee432dc24ecdbb142c5dc5371166cf2d690ebb245b832"',
    `const EXPECTED_GEOMETRY_SIGNATURE := "${NAVY_CHAPEL_GEOMETRY_SIGNATURE}"`,
    `const EXPECTED_LIVE_OWNERSHIP_SIGNATURE := "${NAVY_CHAPEL_OWNERSHIP_SIGNATURE}"`,
    `const PROTOTYPE := preload("res://${NAVY_CHAPEL_PROTOTYPE_PATH}")`,
    '"fallback_allowed": false',
    '"stack_allowed": false',
    '"wall_collision_triangles": EXPECTED_WALL_COLLISION_TRIANGLES',
    '"roof_collision_triangles": EXPECTED_ROOF_COLLISION_TRIANGLES',
    '"roof_in_wall_spray_group": false',
  ]) invariant(adapterText.includes(expected), `Navy Chapel live adapter contract drifted: ${expected}`);
  for (const path of [NAVY_CHAPEL_LIVE_ADAPTER_PATH, NAVY_CHAPEL_CONFIG_PATH, ...NAVY_CHAPEL_RUNTIME_ASSET_PATHS]) {
    invariant(existsSync(absolute(path)) && statSync(absolute(path)).isFile(), `Navy Chapel current runtime asset is missing: ${path}`);
  }
}

function validateActiveD1B201Dispatch(inputs) {
  const contract = inputs.runtimeContracts;
  const config = contract.d1B201Config;
  const sourceMembership = config.source_membership ?? {};
  const authority = config.supplied_record_authority ?? {};
  const chain = config.eligible_public_chain ?? {};
  const translation = config.production_translation ?? {};
  const protectedScope = config.protected_scope ?? {};
  const runtime = config.runtime_contract ?? {};
  invariant(contract.d1B201ConfigSha256 === D1_B201_CONFIG_SHA256, "D1 B201 reviewed config bytes drifted from capture-time authority");
  invariant(contract.d1B201LiveAdapterSha256 === D1_B201_LIVE_ADAPTER_SHA256, "D1 B201 reviewed adapter bytes drifted from capture-time authority");
  invariant(config.schema_version === "ti.d1-b201-live-attachment/1", "D1 B201 live config schema drifted");
  invariant(config.source_key === D1_B201_SOURCE && config.receiver_key === D1_B201_WALL, "D1 B201 live target identity drifted");
  invariant(sourceMembership.source_geometry_sha256 === "2bb86d7269f9fc609ab079c0e31680e734c7b4fd0adcce42e1146c9cd81af764", "D1 B201 frozen source geometry drifted");
  invariant(authority.canonical_stable_json_sha256 === "024b2ed0af4de1a7e8456fcd171e1abc27a212dd72d054a9d9d1d487effa98b3" && authority.host_triangle_count === 80, "D1 B201 supplied wall authority drifted");
  invariant(equalStable(chain.source_edge_indices, [0]) && equalStable(chain.ordered_run_indices, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]), "D1 B201 public WSW run chain drifted");
  invariant(chain.runtime_meter_plan_signature === "7d5f350c8130aee2a95e567741ec8466e5a83a4b412dcb85d2d327786ec2f650", "D1 B201 runtime meter plan drifted");
  invariant(translation.decorative_geometry_signature === D1_B201_DECORATIVE_GEOMETRY_SIGNATURE && translation.decorative_box_instance_count === 172 && translation.decorative_triangle_count === 2064 && translation.host_triangle_count_unchanged === 80 && translation.host_surface_count_delta === 1, "D1 B201 production translation drifted");
  invariant(equalStable(protectedScope.run_indices, Array.from({ length: 30 }, (_, index) => index + 10)) && protectedScope.host_collision_owner_preserved === true && protectedScope.host_spray_owner_preserved === true && protectedScope.roof_untouched === true, "D1 B201 protected receiver scope drifted");
  invariant(runtime.attachment_mode === "receiver_host_material_partition_plus_receiver_relative_render_only_details" && runtime.mesh_instances === 6 && runtime.surfaces === 6 && runtime.triangles === 2064 && runtime.collision_nodes === 0 && runtime.navigation_nodes === 0 && runtime.spray_nodes === 0 && runtime.reference_recognizable === false, "D1 B201 live runtime ownership or self-acceptance boundary drifted");
  const adapterText = contract.d1B201LiveAdapterText;
  for (const expected of [
    `const CONFIG_PATH := "res://${D1_B201_CONFIG_PATH}"`,
    `const SOURCE_KEY := "${D1_B201_SOURCE}"`,
    `const RECEIVER_KEY := "${D1_B201_WALL}"`,
    `const ROOF_KEY := "${D1_B201_ROOF}"`,
    'const EXPECTED_CANONICAL_RECORD_SHA256 := "024b2ed0af4de1a7e8456fcd171e1abc27a212dd72d054a9d9d1d487effa98b3"',
    'const EXPECTED_CANONICAL_ROOF_RECORD_SHA256 := "53994e07ee99632a338d8c577427efac3ca3c584148f4d9ef92a251a49e589ff"',
    `const EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE := "${D1_B201_DECORATIVE_GEOMETRY_SIGNATURE}"`,
    '"protected_generic_runs": range(10, 40)',
    '"host_collision_owner_preserved": true',
    '"host_spray_owner_preserved": true',
    '"collision_nodes": 0',
    '"navigation_nodes": 0',
    '"spray_nodes": 0',
  ]) invariant(adapterText.includes(expected), `D1 B201 live adapter contract drifted: ${expected}`);
  for (const path of [D1_B201_LIVE_ADAPTER_PATH, D1_B201_CONFIG_PATH, ...D1_B201_RUNTIME_ASSET_PATHS]) {
    invariant(existsSync(absolute(path)) && statSync(absolute(path)).isFile(), `D1 B201 current runtime asset is missing: ${path}`);
  }
}

function validateActiveD1B225Dispatch(inputs) {
  const contract = inputs.runtimeContracts;
  const config = contract.d1B225Config;
  const sourceMembership = config.source_membership ?? {};
  const authority = config.supplied_record_authority ?? {};
  const chain = config.eligible_public_chain ?? {};
  const geometry = config.approved_geometry ?? {};
  const translation = config.production_translation ?? {};
  const protectedScope = config.protected_scope ?? {};
  const runtime = config.runtime_contract ?? {};
  invariant(contract.d1B225ConfigSha256 === D1_B225_CONFIG_SHA256, "D1 B225 reviewed config bytes drifted from capture-time authority");
  invariant(contract.d1B225LiveAdapterSha256 === D1_B225_LIVE_ADAPTER_SHA256, "D1 B225 reviewed adapter bytes drifted from capture-time authority");
  invariant(config.schema_version === "ti.d1-b225-live-attachment/1", "D1 B225 live config schema drifted");
  invariant(config.source_key === D1_B225_SOURCE && config.receiver_key === D1_B225_WALL, "D1 B225 live target identity drifted");
  invariant(sourceMembership.source_geometry_sha256 === "d9804e14fbbdc7a258299a7883ffa922741fb016207ee00ddf1682834d19bb2e", "D1 B225 frozen source geometry drifted");
  invariant(authority.canonical_stable_json_sha256 === "7950095b20ea50b989f7f111e6e4bfd45cdc42cda85ac3e0f3c8cd044c836722" && authority.host_triangle_count === 28, "D1 B225 supplied wall authority drifted");
  invariant(equalStable(chain.source_edge_indices, [3]) && equalStable(chain.ordered_run_indices, [10, 11, 12, 13]), "D1 B225 public NNW run chain drifted");
  invariant(chain.runtime_meter_plan_signature === "6c903f808cc5eb6d917cbb1946dda9f1fb02bfeb663bdbfe1846353238d49450", "D1 B225 runtime meter plan drifted");
  invariant(geometry.standalone_geometry_signature === "281a471f6cff9b0530aa51c98cc737d276dc0d9210996a5403d9fe44996dd2a2" && geometry.box_instance_count === 90 && geometry.triangle_count === 1088, "D1 B225 reviewed standalone geometry authority drifted");
  invariant(translation.decorative_geometry_signature === D1_B225_DECORATIVE_GEOMETRY_SIGNATURE && translation.decorative_box_instance_count === 90 && translation.decorative_triangle_count === 1080 && translation.host_triangle_count_unchanged === 28 && translation.host_surface_count_delta === 1, "D1 B225 production translation drifted");
  invariant(equalStable(protectedScope.run_indices, Array.from({ length: 10 }, (_, index) => index)) && protectedScope.host_collision_owner_preserved === true && protectedScope.host_spray_owner_preserved === true && protectedScope.roof_untouched === true, "D1 B225 protected receiver scope drifted");
  invariant(runtime.integration_stage === "production_runtime_attachment" && runtime.attachment_mode === "receiver_host_material_partition_plus_receiver_relative_render_only_details" && runtime.mesh_instances === 2 && runtime.surfaces === 2 && runtime.triangles === 1080 && runtime.collision_nodes === 0 && runtime.navigation_nodes === 0 && runtime.spray_nodes === 0 && runtime.reference_recognizable === false && runtime.catalog_or_registry_promotion === false, "D1 B225 capture-time runtime ownership or self-acceptance boundary drifted");
  const adapterText = contract.d1B225LiveAdapterText;
  for (const expected of [
    `const CONFIG_PATH := "res://${D1_B225_CONFIG_PATH}"`,
    `const SOURCE_KEY := "${D1_B225_SOURCE}"`,
    `const RECEIVER_KEY := "${D1_B225_WALL}"`,
    `const ROOF_KEY := "${D1_B225_ROOF}"`,
    'const EXPECTED_CANONICAL_RECORD_SHA256 := "7950095b20ea50b989f7f111e6e4bfd45cdc42cda85ac3e0f3c8cd044c836722"',
    'const EXPECTED_CANONICAL_ROOF_RECORD_SHA256 := "338afe9681244b8deca0b4f87891a8a91069002b36bc7a9c4fd8564b420778c0"',
    `const EXPECTED_DECORATIVE_GEOMETRY_SIGNATURE := "${D1_B225_DECORATIVE_GEOMETRY_SIGNATURE}"`,
    'const RUN_INDICES: Array[int] = [10, 11, 12, 13]',
    '"protected_generic_runs": range(0, 10)',
    '"host_collision_owner_preserved": true',
    '"host_spray_owner_preserved": true',
    '"collision_nodes": 0',
    '"navigation_nodes": 0',
    '"spray_nodes": 0',
  ]) invariant(adapterText.includes(expected), `D1 B225 live adapter contract drifted: ${expected}`);
  for (const path of [D1_B225_LIVE_ADAPTER_PATH, D1_B225_CONFIG_PATH, ...D1_B225_RUNTIME_ASSET_PATHS]) {
    invariant(existsSync(absolute(path)) && statSync(absolute(path)).isFile(), `D1 B225 current runtime asset is missing: ${path}`);
  }
}

function validateD21441PromotionAuthority(inputs) {
  const contract = inputs.runtimeContracts;
  const exactFiles = [
    [contract.d21441EvidenceManifestPath, D2_1441_EVIDENCE_MANIFEST_PATH, contract.d21441EvidenceManifestSha256, D2_1441_EVIDENCE_MANIFEST_SHA256, "static evidence manifest"],
    [contract.d21441MotionTelemetryManifestPath, D2_1441_MOTION_TELEMETRY_MANIFEST_PATH, contract.d21441MotionTelemetryManifestSha256, D2_1441_MOTION_TELEMETRY_MANIFEST_SHA256, "motion telemetry manifest"],
    [contract.d21441VisualMotionManifestPath, D2_1441_VISUAL_MOTION_MANIFEST_PATH, contract.d21441VisualMotionManifestSha256, D2_1441_VISUAL_MOTION_MANIFEST_SHA256, "visual motion manifest"],
    [contract.d21441PackageVerificationReceiptPath, D2_1441_PACKAGE_VERIFICATION_RECEIPT_PATH, contract.d21441PackageVerificationReceiptSha256, D2_1441_PACKAGE_VERIFICATION_RECEIPT_SHA256, "package verification receipt"],
    [contract.d21441MechanicalReviewPath, D2_1441_MECHANICAL_REVIEW_PATH, contract.d21441MechanicalReviewSha256, D2_1441_MECHANICAL_REVIEW_RECEIPT_SHA256, "mechanical review"],
    [contract.d21441VisualReviewPath, D2_1441_VISUAL_REVIEW_PATH, contract.d21441VisualReviewSha256, D2_1441_VISUAL_REVIEW_RECEIPT_SHA256, "visual review"],
  ];
  for (const [actualPath, expectedPath, actualHash, expectedHash, label] of exactFiles) {
    invariant(actualPath === expectedPath, `D2 1441 ${label} path drifted`);
    invariant(actualHash === expectedHash, `D2 1441 ${label} bytes drifted`);
  }
  invariant(contract.d21441EvidenceTree.file_count === 40 && contract.d21441EvidenceTree.sha256 === D2_1441_EVIDENCE_TREE_SHA256, "D2 1441 canonical 40-file evidence tree drifted");
  invariant(contract.d21441MechanicalReviewSha256 === sha256Bytes(contract.d21441MechanicalReviewText), "D2 1441 mechanical review text/hash binding drifted");
  invariant(contract.d21441VisualReviewSha256 === sha256Bytes(contract.d21441VisualReviewText), "D2 1441 visual review text/hash binding drifted");

  const packetHashes = [
    D2_1441_EVIDENCE_MANIFEST_SHA256,
    D2_1441_MOTION_TELEMETRY_MANIFEST_SHA256,
    D2_1441_VISUAL_MOTION_MANIFEST_SHA256,
    D2_1441_EVIDENCE_TREE_SHA256,
    D2_1441_PACKAGE_VERIFICATION_RECEIPT_SHA256,
  ];
  for (const [reviewText, label] of [
    [contract.d21441MechanicalReviewText, "mechanical review"],
    [contract.d21441VisualReviewText, "visual review"],
  ]) {
    invariant(reviewText.includes("PASS_FOR_1441_PROMOTION_NO_CREDIT"), `D2 1441 ${label} lacks the exact promotion PASS verdict`);
    invariant(reviewText.includes("8/213"), `D2 1441 ${label} does not preserve the capture-time 8/213 boundary`);
    for (const hash of packetHashes) invariant(reviewText.includes(hash), `D2 1441 ${label} does not bind ${hash}`);
  }
  for (const hash of [D2_1441_REVIEWED_WORLD_BUILDER_SHA256, D2_1441_CONFIG_SHA256, D2_1441_LIVE_ADAPTER_SHA256]) {
    invariant(contract.d21441MechanicalReviewText.includes(hash), `D2 1441 mechanical review does not bind ${hash}`);
  }

  const expectedRuntimeTopology = {
    bodies: 466,
    meshes: 959,
    rows: 735,
    shapes: 466,
    surfaces: 974,
    triangles: 69252,
  };
  const expectedPairTopology = {
    bodies: 2,
    meshes: 9,
    shapes: 2,
    surfaces: 9,
    triangles: 1578,
  };
  const evidenceDocuments = [
    [contract.d21441EvidenceManifest, "ti.d2-1441-production-v8-static-evidence/1", "static evidence manifest"],
    [contract.d21441MotionTelemetryManifest, "ti.d2-1441-production-v8-motion-telemetry/1", "motion telemetry manifest"],
    [contract.d21441VisualMotionManifest, "ti.d2-1441-production-v8-visual-motion/1", "visual motion manifest"],
  ];
  for (const [document, expectedSchema, label] of evidenceDocuments) {
    invariant(document.schema_version === expectedSchema, `D2 1441 ${label} schema drifted`);
    invariant(document.authoritative_candidate_packet === true, `D2 1441 ${label} is not the exact authoritative candidate packet`);
    invariant(document.capture_time_recognition_metric === "8/213", `D2 1441 ${label} capture-time metric drifted`);
    invariant(document.recognition_credit === false && document.additional_recognition_credit === false && document.promotion === false, `D2 1441 ${label} improperly self-grants recognition credit or promotion`);
    invariant(document.package_verification_receipt_sha256 === D2_1441_PACKAGE_VERIFICATION_RECEIPT_SHA256, `D2 1441 ${label} package receipt binding drifted`);
    invariant(equalStable(document.runtime_topology, expectedRuntimeTopology), `D2 1441 ${label} runtime topology drifted`);
    invariant(document.production_path_observation?.ordinary_main_already_integrated === true && document.production_path_observation?.attachment_present_at_world_ready === true && document.production_path_observation?.capture_harness_adapter_or_factory_activation_count === 0 && document.production_path_observation?.capture_harness_standalone_scene_activation_count === 0, `D2 1441 ${label} no longer proves the ordinary-main activation route`);
    const bindings = document.bindings ?? {};
    invariant(bindings.source_key === D2_1441_SOURCE && bindings.wall_key === D2_1441_WALL && bindings.roof_key === D2_1441_ROOF, `D2 1441 ${label} target binding drifted`);
    invariant(equalStable(bindings.mapped_public_sse_runs, D2_1441_MAPPED_RUNS) && equalStable(bindings.protected_runs, D2_1441_PROTECTED_RUNS), `D2 1441 ${label} mapped/protected run binding drifted`);
    invariant(bindings.geometry_signature === D2_1441_GEOMETRY_SIGNATURE && bindings.live_ownership_signature === D2_1441_OWNERSHIP_SIGNATURE, `D2 1441 ${label} geometry/ownership binding drifted`);
    invariant(equalStable(bindings.combined_factory_topology, expectedPairTopology) && bindings.wall_collision_triangles === 32 && bindings.roof_collision_triangles === 10 && bindings.decorative_relief_triangles === 1536 && bindings.decorative_relief_collision_triangles === 0, `D2 1441 ${label} paired topology binding drifted`);
    const dependencies = document.source_dependency_hashes ?? {};
    invariant(dependencies[`res://${D2_1441_CONFIG_PATH}`] === D2_1441_CONFIG_SHA256, `D2 1441 ${label} config dependency binding drifted`);
    invariant(dependencies[`res://${D2_1441_LIVE_ADAPTER_PATH}`] === D2_1441_LIVE_ADAPTER_SHA256, `D2 1441 ${label} adapter dependency binding drifted`);
    invariant(dependencies[`res://${WORLD_CHUNK_BUILDER_PATH}`] === D2_1441_REVIEWED_WORLD_BUILDER_SHA256, `D2 1441 ${label} dispatch dependency binding drifted`);
  }
  const staticTarget = contract.d21441EvidenceManifest.target ?? {};
  invariant(staticTarget.source_key === D2_1441_SOURCE && staticTarget.wall_object_key === D2_1441_WALL && staticTarget.roof_object_key === D2_1441_ROOF && staticTarget.chunk_id === "x_-1__z_-1", "D2 1441 static evidence target identity drifted");
  invariant(equalStable(staticTarget.mapped_public_sse_runs, D2_1441_MAPPED_RUNS) && equalStable(staticTarget.protected_runs, D2_1441_PROTECTED_RUNS), "D2 1441 static evidence target run partition drifted");

  const receipt = contract.d21441PackageVerificationReceipt;
  invariant(receipt.schema_version === "ti.d2-1441-production-v8-package-verification/1", "D2 1441 package verification receipt schema drifted");
  invariant(receipt.capture_time_recognition_metric === "8/213" && receipt.recognition_credit === false && receipt.additional_recognition_credit === false && receipt.promotion === false, "D2 1441 package verification receipt improperly self-grants recognition credit or promotion");
  invariant(receipt.source_hashes?.[D2_1441_CONFIG_PATH] === D2_1441_CONFIG_SHA256 && receipt.source_hashes?.[D2_1441_LIVE_ADAPTER_PATH] === D2_1441_LIVE_ADAPTER_SHA256 && receipt.source_hashes?.[WORLD_CHUNK_BUILDER_PATH] === D2_1441_REVIEWED_WORLD_BUILDER_SHA256, "D2 1441 package receipt source closure drifted");
  invariant(equalStable(receipt.runtime_topology, expectedRuntimeTopology), "D2 1441 package receipt runtime topology drifted");
  invariant(receipt.d2_target?.source_key === D2_1441_SOURCE && receipt.d2_target?.wall_object_key === D2_1441_WALL && receipt.d2_target?.roof_object_key === D2_1441_ROOF && receipt.d2_target?.geometry_signature === D2_1441_GEOMETRY_SIGNATURE && receipt.d2_target?.live_ownership_signature === D2_1441_OWNERSHIP_SIGNATURE, "D2 1441 package receipt target binding drifted");
  for (const key of ["source_package_contract_pass", "mounted_package_contract_pass", "generic_mounted_pck_content_audit_pass", "headless_exported_main_smoke_pass", "native_exported_main_smoke_pass", "mounted_d2_runtime_closure_present", "mounted_ordinary_main_present"]) {
    invariant(receipt[key] === true, `D2 1441 package receipt ${key} is not passing`);
  }
  invariant(receipt.mounted_standalone_activation_routes_absent === true && receipt.mounted_override_absent === true && receipt.postcapture_catalog_or_registry_mutation === false, "D2 1441 package receipt route or postcapture-mutation boundary drifted");
}

function validateActiveD21441Dispatch(inputs) {
  const contract = inputs.runtimeContracts;
  const config = contract.d21441Config;
  const target = config.target ?? {};
  const art = config.reviewed_art ?? {};
  const pair = config.live_pair_contract ?? {};
  const transition = config.topology_transition ?? {};
  const truth = config.truth_boundary ?? {};
  invariant(contract.d21441ConfigSha256 === D2_1441_CONFIG_SHA256, "D2 1441 reviewed config bytes drifted from capture-time authority");
  invariant(contract.d21441LiveAdapterSha256 === D2_1441_LIVE_ADAPTER_SHA256, "D2 1441 reviewed adapter bytes drifted from capture-time authority");
  invariant(contract.acceptedWorldBuilderSha256 === D2_1441_REVIEWED_WORLD_BUILDER_SHA256, "D2 1441 reviewed world-builder bytes drifted from capture-time authority");
  invariant(config.schema_version === "ti.d2-1441-chinook-live-replacement/1", "D2 1441 live config schema drifted");
  invariant(target.source_key === D2_1441_SOURCE && target.wall_object_key === D2_1441_WALL && target.roof_object_key === D2_1441_ROOF && target.chunk_id === "x_-1__z_-1", "D2 1441 live target identity drifted");
  invariant(target.chunk_sha256 === "5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b" && target.source_geometry_sha256 === "952df7a4edca5dbaec7d74cb795b564cb1fa5567ea737d1a861e222b29ddf07f", "D2 1441 frozen source/chunk geometry drifted");
  invariant(target.canonical_wall_record_sha256 === "00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c" && target.canonical_roof_record_sha256 === "e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55", "D2 1441 canonical supplied pair drifted");
  invariant(art.factory_geometry_signature === D2_1441_GEOMETRY_SIGNATURE && equalStable(art.mapped_public_sse_runs, D2_1441_MAPPED_RUNS) && equalStable(art.protected_runs, D2_1441_PROTECTED_RUNS), "D2 1441 reviewed art/run partition drifted");
  invariant(pair.pair_members === 2 && pair.factory_calls === 1 && pair.fallback_allowed === false && pair.partial_pair_allowed === false && pair.stack_allowed === false, "D2 1441 paired replacement lifecycle drifted");
  invariant(pair.wall?.mesh_instances === 8 && pair.wall?.visual_triangles === 1568 && pair.wall?.collision_triangles === 32 && pair.wall?.spray_receiver_wall_owners === 1, "D2 1441 wall topology/ownership drifted");
  invariant(pair.roof?.mesh_instances === 1 && pair.roof?.visual_triangles === 10 && pair.roof?.collision_triangles === 10 && pair.roof?.spray_receiver_wall_owners === 0 && pair.roof?.spray_ray_blocking === true && pair.roof?.truthful_world_solid_landing === true, "D2 1441 roof topology/ownership drifted");
  invariant(pair.decorative_relief?.visual_triangles === 1536 && pair.decorative_relief?.collision_triangles === 0 && pair.decorative_relief?.navigation_nodes === 0, "D2 1441 decorative relief ownership drifted");
  invariant(transition.live_uncredited_candidate?.playable_rows === 735 && transition.live_uncredited_candidate?.mesh_instances === 959 && transition.live_uncredited_candidate?.surfaces === 974 && transition.live_uncredited_candidate?.triangles === 69252 && transition.live_uncredited_candidate?.static_bodies === 466 && transition.live_uncredited_candidate?.shapes === 466, "D2 1441 reviewed live topology drifted");
  invariant(transition.delta?.playable_rows === 0 && transition.delta?.mesh_instances === 7 && transition.delta?.surfaces === 7 && transition.delta?.triangles === 1536 && transition.delta?.static_bodies === 0 && transition.delta?.shapes === 0, "D2 1441 topology delta drifted");
  invariant(truth.runtime_attachment === true && truth.candidate_is_uncredited === true && truth.accepted_authority_schema === "ti.facade-runtime-registry/8" && truth.accepted_recognition_metric === "8/213" && truth.catalog_or_registry_promoted === false && truth.recognition_accepted === false && truth.as_built_fidelity_claimed === false && truth.horizontal_source_footprint_changed === false && truth.source_photography_shipped === false, "D2 1441 capture-time no-credit truth boundary drifted");
  const adapterText = contract.d21441LiveAdapterText;
  for (const expected of [
    `const CONFIG_PATH := "res://${D2_1441_CONFIG_PATH}"`,
    `const SOURCE_KEY := "${D2_1441_SOURCE}"`,
    `const WALL_KEY := "${D2_1441_WALL}"`,
    `const ROOF_KEY := "${D2_1441_ROOF}"`,
    'const CANONICAL_WALL_RECORD_SHA256 := "00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c"',
    'const CANONICAL_ROOF_RECORD_SHA256 := "e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55"',
    `const EXPECTED_GEOMETRY_SIGNATURE := "${D2_1441_GEOMETRY_SIGNATURE}"`,
    `const EXPECTED_LIVE_OWNERSHIP_SIGNATURE := "${D2_1441_OWNERSHIP_SIGNATURE}"`,
    `const PROTOTYPE := preload("res://${D2_1441_PROTOTYPE_PATH}")`,
    'const WALL_COLLISION_TRIANGLE_RANGE := [0, 31]',
    'const ROOF_COLLISION_TRIANGLE_RANGE := [32, 41]',
  ]) invariant(adapterText.includes(expected), `D2 1441 live adapter contract drifted: ${expected}`);
  for (const path of [D2_1441_LIVE_ADAPTER_PATH, D2_1441_CONFIG_PATH, ...D2_1441_RUNTIME_ASSET_PATHS]) {
    invariant(existsSync(absolute(path)) && statSync(absolute(path)).isFile(), `D2 1441 current runtime asset is missing: ${path}`);
  }
  validateD21441PromotionAuthority(inputs);
}

function validateD21439PromotionAuthority() {
  const receipt = REVIEW_RECEIPTS[D2_1439_REVIEW_ID];
  const fileFields = [
    ["evidence_manifest_path", "evidence_manifest_sha256"],
    ["motion_telemetry_manifest_path", "motion_telemetry_manifest_sha256"],
    ["visual_motion_manifest_path", "visual_motion_manifest_sha256"],
    ["package_verification_receipt_path", "package_verification_receipt_sha256"],
    ["mechanical_review_path", "mechanical_review_receipt_sha256"],
    ["review_path", "review_receipt_sha256"],
  ];
  for (const [pathField, hashField] of fileFields) invariant(sha256File(absolute(receipt[pathField])) === receipt[hashField], `D2 1439 ${hashField} artifact drifted`);
  const review = readFileSync(absolute(receipt.review_path), "utf8");
  invariant(review.includes("PASS_FOR_1439_SERIALIZED_PROMOTION_NO_CREDIT") && review.includes("9/213"), "D2 1439 independent packet attestation or capture metric drifted");
  for (const key of ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "evidence_tree_sha256"]) invariant(review.includes(receipt[key]), `D2 1439 packet review lost ${key}`);
  // The seventh binding is the independent packet attestation of the historical
  // visual decision. The evidence-tree binding is the image tree digest, not
  // the JSON document hash; both identities remain explicit.
  const treePath = `${D2_1439_EVIDENCE_ROOT}/evidence-tree.json`;
  invariant(sha256File(absolute(treePath)) === "a624794065ed89ccbc67f6f9caf77b02729a6e9c0b08eef8e495e63156bd9dde", "D2 1439 image-tree document drifted");
  const tree = readJson(treePath);
  invariant(tree.files.length === 31 && tree.tree_sha256 === D2_1439_EVIDENCE_TREE_SHA256, "D2 1439 native image count/tree binding drifted");
  const rows = tree.files.map((entry) => {
    invariant(/^(?:images|reviewed-motion-frames)\/[A-Za-z0-9_./-]+\.(png|jpg)$/u.test(entry.path) && !entry.path.includes(".."), "D2 1439 image path escapes packet");
    const path = absolute(`${D2_1439_EVIDENCE_ROOT}/${entry.path}`);
    invariant(statSync(path).size === entry.bytes && sha256File(path) === entry.sha256, `D2 1439 original image drifted: ${entry.path}`);
    return `${entry.path}\0${entry.sha256}\0${entry.bytes}\n`;
  }).sort();
  assertUnique(tree.files.map((entry) => entry.path), "D2 1439 native images");
  invariant(sha256Bytes(rows.join("")) === D2_1439_EVIDENCE_TREE_SHA256, "D2 1439 native image tree digest drifted");
  for (const path of [receipt.evidence_manifest_path, receipt.motion_telemetry_manifest_path, receipt.visual_motion_manifest_path, receipt.mechanical_review_path]) {
    const document = readJson(path);
    invariant(document.derived_normalized_summary === true && document.not_a_captured_original === true && document.raw_originals_rewritten === false, "D2 1439 derived/original provenance drifted");
    invariant(document.truth_boundary.recognition_metric === "9/213" && document.truth_boundary.recognition_credit === false && document.truth_boundary.promotion === false, "D2 1439 historical evidence self-grants credit");
  }
  const pkg = readJson(receipt.package_verification_receipt_path);
  invariant(pkg.decision === "PASS_FOR_1439_CANDIDATE_PACKAGE_AND_PROMOTION_REVIEW_NO_CREDIT" && pkg.recognition_metric === "9/213" && pkg.recognition_credit === false && pkg.promotion === false, "D2 1439 candidate package decision/truth drifted");
  invariant(equalStable(pkg.actual_world, {rows:735, meshes:968, surfaces:983, triangles:71156, bodies:466, shapes:467}), "D2 1439 package measured topology drifted");
  for (const key of ["all_before_after_app_bytes_exact", "mounted_override_absent", "mounted_standalone_activation_routes_absent", "mounted_package_component_contract_pass", "generic_mounted_pck_content_audit_pass", "headless_exported_main_smoke_pass", "native_exported_main_smoke_pass"]) invariant(pkg[key] === true, `D2 1439 package ${key} not passing`);
}

function validateD21444PromotionAuthority() {
  const receipt = REVIEW_RECEIPTS[D2_1444_REVIEW_ID];
  const fileFields = [
    ["evidence_manifest_path", "evidence_manifest_sha256"],
    ["motion_telemetry_manifest_path", "motion_telemetry_manifest_sha256"],
    ["visual_motion_manifest_path", "visual_motion_manifest_sha256"],
    ["package_verification_receipt_path", "package_verification_receipt_sha256"],
    ["mechanical_review_path", "mechanical_review_receipt_sha256"],
    ["review_path", "review_receipt_sha256"],
  ];
  for (const [pathField, hashField] of fileFields) invariant(sha256File(absolute(receipt[pathField])) === receipt[hashField], `D2 1444 ${hashField} artifact drifted`);
  const review = readFileSync(absolute(receipt.review_path), "utf8");
  invariant(review.includes("PASS_FOR_1444_SERIALIZED_PROMOTION_NO_CREDIT") && review.includes("9/213"), "D2 1444 independent packet attestation or capture metric drifted");
  for (const key of ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "mechanical_review_receipt_sha256", "evidence_tree_sha256"]) invariant(review.includes(receipt[key]), `D2 1444 packet review lost ${key}`);
  // The seventh binding is the independent packet attestation of the historical
  // visual decision. The evidence-tree binding is the image tree digest, not
  // the JSON document hash; both identities remain explicit.
  const treePath = `${D2_1444_EVIDENCE_ROOT}/evidence-tree.json`;
  invariant(sha256File(absolute(treePath)) === "9f353b1c84fb30a35209d5899ae7ff2861c64d74eb2330a441c0ae37f28131b6", "D2 1444 image-tree document drifted");
  const tree = readJson(treePath);
  invariant(tree.files.length === 33 && tree.tree_sha256 === D2_1444_EVIDENCE_TREE_SHA256, "D2 1444 native image count/tree binding drifted");
  const rows = tree.files.map((entry) => {
    invariant(/^(?:images|reviewed-motion-frames)\/[A-Za-z0-9_./-]+\.(png|jpg)$/u.test(entry.path) && !entry.path.includes(".."), "D2 1444 image path escapes packet");
    const path = absolute(`${D2_1444_EVIDENCE_ROOT}/${entry.path}`);
    invariant(statSync(path).size === entry.bytes && sha256File(path) === entry.sha256, `D2 1444 original image drifted: ${entry.path}`);
    return `${entry.path}\0${entry.sha256}\0${entry.bytes}\n`;
  }).sort();
  assertUnique(tree.files.map((entry) => entry.path), "D2 1444 native images");
  invariant(sha256Bytes(rows.join("")) === D2_1444_EVIDENCE_TREE_SHA256, "D2 1444 native image tree digest drifted");
  for (const path of [receipt.evidence_manifest_path, receipt.motion_telemetry_manifest_path, receipt.visual_motion_manifest_path, receipt.mechanical_review_path]) {
    const document = readJson(path);
    invariant(document.derived_normalized_summary === true && document.not_a_captured_original === true && document.raw_originals_rewritten === false, "D2 1444 derived/original provenance drifted");
    invariant(document.truth_boundary.recognition_metric === "10/213" && document.truth_boundary.capture_time_recognition_metric === "9/213" && document.truth_boundary.recognition_credit === false && document.truth_boundary.promotion === false, "D2 1444 historical evidence self-grants credit");
  }
  const pkg = readJson(receipt.package_verification_receipt_path);
  invariant(pkg.decision === "PASS_1444_CANDIDATE_PACKAGE_NO_CREDIT" && pkg.recognition_metric === "10/213" && pkg.capture_time_recognition_metric === "9/213" && pkg.recognition_credit === false && pkg.promotion === false, "D2 1444 candidate package decision/truth drifted");
  invariant(equalStable(pkg.actual_world, {rows:735, meshes:977, surfaces:992, triangles:71828, bodies:466, shapes:468}), "D2 1444 package measured topology drifted");
  invariant(equalStable(pkg.verified.actual_1444_wall, [10,10,716,1,2]) && equalStable(pkg.verified.actual_1439_wall, [10,10,512,1,2]) && equalStable(pkg.verified.actual_roof_each_pair, [1,1,10,1,1]) && equalStable(pkg.verified["1444_collision_partitions"], [64,40,10]), "D2 1444 real packaged pair coverage drifted");
  invariant(pkg.verified.no_activation_overrides === true && equalStable(pkg.verified.private_paths_raw_banned, [0,0,0]) && pkg.verified.deep_strict_signature === true, "D2 1444 package privacy/signing/activation boundary drifted");
  invariant(pkg.independent_package_review.raw_original_sha256 === "d87e2205a6b89fcdced00c67c3478af973e999d7c710b7195c7cec194497b41c" && pkg.final_byte_pid_gate.raw_original_sha256 === "951ca2e9161f9f967a33867320fdd05f238b734a243ac8d4de1522ad884c8480", "D2 1444 independent exact-byte/PID authority drifted");
  invariant(equalStable(pkg.independent_completion_receipts.map((r) => r.stage), ["mounted-component-001", "mounted-privacy-001", "release-headless-smoke-001", "release-native-smoke-001"]) && pkg.independent_completion_receipts.every((r) => r.status === "terminal" && r.exit_code === 0 && r.clean_log === true && r.pins_before_after_exact === true), "D2 1444 independent supported package stages incomplete");
  invariant(pkg.coverage_split.editor_mounted.includes("target-record") && pkg.coverage_split.source_and_signed_release.includes("complete world"), "D2 1444 mounted-target versus signed-release world coverage drifted");
  invariant(pkg.owner_completion_receipts.filter((r) => r.exit_code !== 0).length === 2, "D2 1444 preserved owner mounted failures drifted");
}

function validateActiveD21439Dispatch(inputs) {
  const c = inputs.runtimeContracts;
  invariant(c.d21439LiveAdapterSha256 === D2_1439_LIVE_ADAPTER_SHA256 && c.d21439ConfigSha256 === D2_1439_CONFIG_SHA256, "D2 1439 reviewed adapter/config bytes drifted");
  invariant(c.d21439PrototypeSha256 === "797dfb3075dacdf24a32b4ee0fa4959c296b35ae2d51f2d3c4dbba407fead3b7" && c.d21439PrototypeConfigSha256 === "1217ae0a101f0f1951a3c12303d11af3aace225745922a09aed276b1958553be" && c.d21439SiteKitSha256 === "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd", "D2 1439 reviewed factory closure drifted");
  invariant(sha256File(absolute("game/scripts/player/player_camera.gd")) === "1d53f11cc3d9de00d4bb580aa6322c6f53b0080e5b9e1e3b18baeefd52125cc3", "D2 1439 accepted safe camera drifted");
  const config = c.d21439Config;
  invariant(config.target.source_key === D2_1439_SOURCE && config.target.wall_object_key === D2_1439_WALL && config.target.roof_object_key === D2_1439_ROOF, "D2 1439 pair identity drifted");
  invariant(config.live_pair_contract.wall.shapes === 2 && config.live_pair_contract.wall.eligible_exterior_triangles === 62 && config.live_pair_contract.wall.noneligible_closed_recess_triangles === 30 && equalStable(config.live_pair_contract.wall.shape_order, ["eligible_exterior", "noneligible_closed_recess"]), "D2 1439 exterior/recess ownership drifted");
  invariant(config.truth_boundary.accepted_recognition_metric === "9/213" && config.truth_boundary.candidate_is_uncredited === true, "D2 1439 capture-time adapter truth drifted");
  for (const path of [D2_1439_LIVE_ADAPTER_PATH, D2_1439_CONFIG_PATH, ...D2_1439_RUNTIME_ASSET_PATHS]) invariant(existsSync(absolute(path)) && statSync(absolute(path)).isFile(), `D2 1439 runtime asset missing: ${path}`);
  validateD21439PromotionAuthority();
}

function validateActiveD21444Dispatch(inputs) {
  const c = inputs.runtimeContracts;
  invariant(c.d21444LiveAdapterSha256 === D2_1444_LIVE_ADAPTER_SHA256 && c.d21444ConfigSha256 === D2_1444_CONFIG_SHA256, "D2 1444 reviewed adapter/config bytes drifted");
  invariant(c.d21444PrototypeSha256 === "afe74e5254af720cd855fb8dbadcb71a283d0c8b2d0f79c9565dd2e62b6e9d42" && c.d21444PrototypeConfigSha256 === "22efb2fa24ea1db245f8fe204e3f029312da59a7a67644d2f1464f02661046ef" && c.d21444SiteKitSha256 === "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd", "D2 1444 reviewed factory closure drifted");
  invariant(sha256File(absolute("game/scripts/player/player_camera.gd")) === "1d53f11cc3d9de00d4bb580aa6322c6f53b0080e5b9e1e3b18baeefd52125cc3", "D2 1444 accepted safe camera drifted");
  const config = c.d21444Config;
  invariant(config.target.source_key === D2_1444_SOURCE && config.target.wall_object_key === D2_1444_WALL && config.target.roof_object_key === D2_1444_ROOF, "D2 1444 pair identity drifted");
  invariant(config.live_pair_contract.wall.shapes === 2 && config.live_pair_contract.wall.eligible_exterior_triangles === 64 && config.live_pair_contract.wall.noneligible_closed_recess_triangles === 40 && equalStable(config.live_pair_contract.wall.shape_order, ["eligible_exterior", "noneligible_closed_recess"]), "D2 1444 exterior/recess ownership drifted");
  invariant(config.truth_boundary.accepted_recognition_metric === "9/213" && config.truth_boundary.candidate_is_uncredited === true, "D2 1444 capture-time adapter truth drifted");
  for (const path of [D2_1444_LIVE_ADAPTER_PATH, D2_1444_CONFIG_PATH, ...D2_1444_RUNTIME_ASSET_PATHS]) invariant(existsSync(absolute(path)) && statSync(absolute(path)).isFile(), `D2 1444 runtime asset missing: ${path}`);
  validateD21444PromotionAuthority();
}

function building3BehaviorContract() {
  return {
    collision_contract: {
      collision_matches_visible_geometry: true,
      roof_landing_world_solid: true,
      spray_ownership: "wall_only",
      wall_world_solid: true,
    },
    facade_contract: {
      collision_owner: "massing_wall",
      deterministic_signature: "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8",
      render_only: true,
      runtime_bound_to_wall_massing: true,
    },
    geometry_contract: {
      generated_bytes_unchanged: true,
      horizontal_source_footprint_preserved: true,
      profile_signature: "f82192fe9ebeb04a6da1222bcd84afd217f163ff6ce1cceed826a5d436dd1693",
      roof_geometry_signature: "2dee9acf24616423230895d70827acb56c8f402a56ac1fe8e4a93d2409b34b63",
      roof_triangles: 675,
      topology_delta_triangles: 766,
      wall_geometry_signature: "e03f830e6a41da16107b5db14bcb8a8ff9f43b46f9df89b1f157958cc68909d4",
      wall_triangles: 236,
    },
    parity_status: "exact_current_behavior_and_dependency_set_verified",
    replacement_contract: {
      dispatch_order: "target_specific_before_generic",
      receiver_roles: ["wall", "roof"],
      roof_object_key: BUILDING_3_ROOF,
      source_key: BUILDING_3_SOURCE,
      wall_object_key: BUILDING_3_WALL,
    },
    schema_version: "ti.building-3-runtime-parity/1",
  };
}

function isleHouseBehaviorContract() {
  return {
    acceptance_contract: {
      accepted_physical_unit_id: ISLE_HOUSE_UNIT_ID,
      independent_live_review_receipt_sha256: ISLE_HOUSE_LIVE_REVIEW_RECEIPT_SHA256,
      numerator_effect: 1,
      part_source_keys_are_not_units: [...ISLE_HOUSE_PARTS],
      reference_recognizable: true,
    },
    geometry_contract: {
      live_signature: ISLE_HOUSE_LIVE_SIGNATURE,
      overlay_mesh_instances: 7,
      overlay_repair_signature: ISLE_HOUSE_REPAIR_SIGNATURE,
      overlay_surfaces: 11,
      overlay_triangles: 2242,
      world_topology_scope: PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE,
      world_mesh_instances: 944,
      world_records: 735,
      world_static_bodies: 466,
      world_surfaces: 957,
      world_triangles: 64572,
      world_shapes: 466,
    },
    ownership_contract: {
      decorative_collision_nodes: 0,
      decorative_navigation_nodes: 0,
      decorative_spray_nodes: 0,
      high_receiver_unchanged: true,
      low_receiver_is_sole_collision_and_spray_owner: true,
    },
    replacement_contract: {
      rejected_overlay_fallback_allowed: false,
      stacking_allowed: false,
      target_receiver_key: ISLE_HOUSE_LOW_WALL,
      target_source_key: ISLE_HOUSE_LOW_SOURCE,
    },
    schema_version: "ti.isle-house-variant-c-live-parity/1",
    truth_boundary: {
      as_built_fidelity_claimed: false,
      game_distinctive_claimed: false,
      receiver_complete_inferred_from_art: false,
    },
  };
}

function navyChapelBehaviorContract() {
  return {
    acceptance_contract: {
      accepted_physical_unit_id: unitId(NAVY_CHAPEL_SOURCE),
      independent_live_review_receipt_sha256: NAVY_CHAPEL_LIVE_REVIEW_RECEIPT_SHA256,
      numerator_effect: 1,
      reference_recognizable: true,
      wall_and_roof_are_one_physical_unit: true,
    },
    geometry_contract: {
      canonical_roof_record_sha256: "54bcd378997d0778bdaee432dc24ecdbb142c5dc5371166cf2d690ebb245b832",
      canonical_wall_record_sha256: "69769fef402b480f1626fdce47e6d4ad49ecb710dab2b2e7373e5efa5acf0080",
      horizontal_source_footprint_preserved: true,
      visual_geometry_signature: NAVY_CHAPEL_GEOMETRY_SIGNATURE,
      visual_mesh_instances: 6,
      visual_surfaces: 6,
      visual_triangles: 540,
      world_topology_scope: PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE,
      world_mesh_instances: 944,
      world_records: 735,
      world_shapes: 466,
      world_static_bodies: 466,
      world_surfaces: 957,
      world_triangles: 64572,
    },
    ownership_contract: {
      live_ownership_signature: NAVY_CHAPEL_OWNERSHIP_SIGNATURE,
      navigation_owner_count: 0,
      roof_collision_triangles: 50,
      roof_is_wall_spray_receiver: false,
      shape_count: 2,
      spray_owner_count: 1,
      structural_owner_count: 2,
      wall_collision_triangles: 94,
      wall_is_sole_spray_receiver: true,
    },
    replacement_contract: {
      actual_supplied_chunk_pair_required: true,
      fallback_allowed: false,
      generic_stack_allowed: false,
      roof_object_key: NAVY_CHAPEL_ROOF,
      source_key: NAVY_CHAPEL_SOURCE,
      wall_object_key: NAVY_CHAPEL_WALL,
    },
    schema_version: "ti.navy-chapel-187-live-parity/1",
    truth_boundary: {
      as_built_fidelity_claimed: false,
      game_distinctive_claimed: false,
      protected_runs_module_free: true,
      receiver_complete_inferred_from_art: false,
      side_count_and_spacing_are_production_inference: true,
    },
  };
}

function d1B201BehaviorContract() {
  return {
    acceptance_contract: {
      accepted_physical_unit_id: unitId(D1_B201_SOURCE),
      capture_time_recognition_metric: "6/213",
      evidence_manifest_sha256: D1_B201_EVIDENCE_MANIFEST_SHA256,
      independent_live_review_receipt_sha256: D1_B201_LIVE_REVIEW_RECEIPT_SHA256,
      numerator_effect: 1,
      reference_recognizable: true,
    },
    geometry_contract: {
      canonical_roof_record_sha256: "53994e07ee99632a338d8c577427efac3ca3c584148f4d9ef92a251a49e589ff",
      canonical_wall_record_sha256: "024b2ed0af4de1a7e8456fcd171e1abc27a212dd72d054a9d9d1d487effa98b3",
      decorative_box_instances: 172,
      decorative_geometry_signature: D1_B201_DECORATIVE_GEOMETRY_SIGNATURE,
      decorative_mesh_instances: 6,
      decorative_surfaces: 6,
      decorative_triangles: 2064,
      eligible_host_triangles: 20,
      host_triangles: 80,
      protected_host_triangles: 60,
      world_topology_scope: PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE,
      world_mesh_instances: 950,
      world_records: 735,
      world_shapes: 466,
      world_static_bodies: 466,
      world_surfaces: 964,
      world_triangles: 66636,
    },
    ownership_contract: {
      decorative_collision_nodes: 0,
      decorative_navigation_nodes: 0,
      decorative_spray_nodes: 0,
      host_collision_owner_preserved: true,
      host_mesh_preserved: true,
      host_spray_owner_preserved: true,
      navigation_owner_count: 0,
      shape_count: 1,
      spray_owner_count: 1,
      structural_owner_count: 1,
    },
    replacement_contract: {
      actual_supplied_chunk_pair_required: true,
      eligible_run_indices: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      fallback_allowed: false,
      host_material_partition: true,
      protected_run_indices: Array.from({ length: 30 }, (_, index) => index + 10),
      receiver_relative_render_only_attachment: true,
      roof_object_key: D1_B201_ROOF,
      source_key: D1_B201_SOURCE,
      stacking_allowed: false,
      wall_object_key: D1_B201_WALL,
    },
    schema_version: "ti.d1-b201-live-parity/1",
    truth_boundary: {
      as_built_fidelity_claimed: false,
      counts_cadence_dimensions_are_production_inference: true,
      game_distinctive_claimed: false,
      reference_pixels_packaged: false,
      receiver_complete_inferred_from_art: false,
      service_and_unobserved_sides_untouched: true,
    },
  };
}

function d1B225BehaviorContract() {
  return {
    acceptance_contract: {
      accepted_physical_unit_id: unitId(D1_B225_SOURCE),
      capture_time_recognition_metric: "7/213",
      evidence_manifest_sha256: D1_B225_EVIDENCE_MANIFEST_SHA256,
      evidence_tree_sha256: D1_B225_EVIDENCE_TREE_SHA256,
      independent_live_review_receipt_sha256: D1_B225_LIVE_REVIEW_RECEIPT_SHA256,
      numerator_effect: 1,
      reference_recognizable: true,
    },
    geometry_contract: {
      canonical_roof_record_sha256: "338afe9681244b8deca0b4f87891a8a91069002b36bc7a9c4fd8564b420778c0",
      canonical_wall_record_sha256: "7950095b20ea50b989f7f111e6e4bfd45cdc42cda85ac3e0f3c8cd044c836722",
      decorative_box_instances: 90,
      decorative_geometry_signature: D1_B225_DECORATIVE_GEOMETRY_SIGNATURE,
      decorative_mesh_instances: 2,
      decorative_surfaces: 2,
      decorative_triangles: 1080,
      eligible_host_triangles: 8,
      host_triangles: 28,
      protected_host_triangles: 20,
      world_mesh_instances: 952,
      world_records: 735,
      world_shapes: 466,
      world_static_bodies: 466,
      world_surfaces: 967,
      world_topology_scope: PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE,
      world_triangles: 67716,
    },
    ownership_contract: {
      decorative_collision_nodes: 0,
      decorative_navigation_nodes: 0,
      decorative_spray_nodes: 0,
      host_collision_owner_preserved: true,
      host_mesh_preserved: true,
      host_spray_owner_preserved: true,
      navigation_owner_count: 0,
      shape_count: 1,
      spray_owner_count: 1,
      structural_owner_count: 1,
    },
    replacement_contract: {
      actual_supplied_chunk_pair_required: true,
      eligible_run_indices: [10, 11, 12, 13],
      fallback_allowed: false,
      host_material_partition: true,
      protected_run_indices: Array.from({ length: 10 }, (_, index) => index),
      receiver_relative_render_only_attachment: true,
      roof_object_key: D1_B225_ROOF,
      source_key: D1_B225_SOURCE,
      stacking_allowed: false,
      wall_object_key: D1_B225_WALL,
    },
    schema_version: "ti.d1-b225-production-live-parity/1",
    truth_boundary: {
      as_built_fidelity_claimed: false,
      counts_cadence_dimensions_are_production_inference: true,
      game_distinctive_claimed: false,
      lower_and_unobserved_sides_untouched: true,
      reference_pixels_packaged: false,
      receiver_complete_inferred_from_art: false,
    },
  };
}

function d21441BehaviorContract() {
  return {
    acceptance_contract: {
      accepted_physical_unit_id: unitId(D2_1441_SOURCE),
      capture_time_recognition_metric: "8/213",
      evidence_manifest_sha256: D2_1441_EVIDENCE_MANIFEST_SHA256,
      evidence_tree_sha256: D2_1441_EVIDENCE_TREE_SHA256,
      independent_live_review_receipt_sha256: D2_1441_VISUAL_REVIEW_RECEIPT_SHA256,
      mechanical_review_receipt_sha256: D2_1441_MECHANICAL_REVIEW_RECEIPT_SHA256,
      motion_telemetry_manifest_sha256: D2_1441_MOTION_TELEMETRY_MANIFEST_SHA256,
      numerator_effect: 1,
      package_verification_receipt_sha256: D2_1441_PACKAGE_VERIFICATION_RECEIPT_SHA256,
      reference_recognizable: true,
      visual_motion_manifest_sha256: D2_1441_VISUAL_MOTION_MANIFEST_SHA256,
      wall_and_roof_are_one_physical_unit: true,
    },
    geometry_contract: {
      canonical_roof_record_sha256: "e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55",
      canonical_wall_record_sha256: "00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c",
      horizontal_source_footprint_preserved: true,
      topology_delta_mesh_instances: 7,
      topology_delta_records: 0,
      topology_delta_shapes: 0,
      topology_delta_static_bodies: 0,
      topology_delta_surfaces: 7,
      topology_delta_triangles: 1536,
      visual_geometry_signature: D2_1441_GEOMETRY_SIGNATURE,
      visual_mesh_instances: 9,
      visual_surfaces: 9,
      visual_triangles: 1578,
      world_mesh_instances: 959,
      world_records: 735,
      world_shapes: 466,
      world_static_bodies: 466,
      world_surfaces: 974,
      world_topology_scope: PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE,
      // Historical pre-1439 whole-world integration includes accepted B1 returns; D2 capture/component identities stay frozen.
      world_triangles: 70692,
    },
    ownership_contract: {
      decorative_collision_triangles: 0,
      decorative_navigation_nodes: 0,
      decorative_relief_triangles: 1536,
      live_ownership_signature: D2_1441_OWNERSHIP_SIGNATURE,
      navigation_owner_count: 0,
      roof_collision_triangles: 10,
      roof_is_wall_spray_receiver: false,
      roof_world_solid_landing: true,
      shape_count: 2,
      spray_owner_count: 1,
      structural_owner_count: 2,
      wall_collision_triangles: 32,
      wall_is_sole_spray_receiver: true,
    },
    replacement_contract: {
      actual_supplied_chunk_pair_required: true,
      fallback_allowed: false,
      generic_stack_allowed: false,
      mapped_public_run_indices: [...D2_1441_MAPPED_RUNS],
      partial_pair_allowed: false,
      protected_run_indices: [...D2_1441_PROTECTED_RUNS],
      roof_object_key: D2_1441_ROOF,
      source_key: D2_1441_SOURCE,
      wall_object_key: D2_1441_WALL,
    },
    schema_version: "ti.d2-1441-production-live-parity/1",
    truth_boundary: {
      as_built_fidelity_claimed: false,
      capture_time_candidate_promoted: false,
      capture_time_recognition_credit: false,
      game_distinctive_claimed: false,
      reference_pixels_packaged: false,
      receiver_complete_inferred_from_art: false,
      unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference: true,
      unobserved_sides_protected: true,
    },
  };
}

function d21439BehaviorContract() {
  return {
    acceptance_contract: {
      accepted_physical_unit_id: unitId(D2_1439_SOURCE),
      capture_time_recognition_metric: "9/213",
      evidence_manifest_sha256: D2_1439_EVIDENCE_MANIFEST_SHA256,
      evidence_tree_sha256: D2_1439_EVIDENCE_TREE_SHA256,
      independent_live_review_receipt_sha256: D2_1439_VISUAL_REVIEW_RECEIPT_SHA256,
      mechanical_review_receipt_sha256: D2_1439_MECHANICAL_REVIEW_RECEIPT_SHA256,
      motion_telemetry_manifest_sha256: D2_1439_MOTION_TELEMETRY_MANIFEST_SHA256,
      numerator_effect: 1,
      package_verification_receipt_sha256: D2_1439_PACKAGE_VERIFICATION_RECEIPT_SHA256,
      reference_recognizable: true,
      visual_motion_manifest_sha256: D2_1439_VISUAL_MOTION_MANIFEST_SHA256,
      wall_and_roof_are_one_physical_unit: true,
    },
    geometry_contract: {
      canonical_roof_record_sha256: "ab98ae1442174841c0d9ae3aeb344991e73c2b85bf07252d2dc12d834ac0f8c0",
      canonical_wall_record_sha256: "0a0b5d7c002a3364714343704404e3e37fa1e55461c3bfae6ae0766d59bb8b11",
      horizontal_source_footprint_preserved: true,
      topology_delta_mesh_instances: 9,
      topology_delta_records: 0,
      topology_delta_shapes: 1,
      topology_delta_static_bodies: 0,
      topology_delta_surfaces: 9,
      topology_delta_triangles: 464,
      visual_geometry_signature: D2_1439_GEOMETRY_SIGNATURE,
      visual_mesh_instances: 11,
      visual_surfaces: 11,
      visual_triangles: 522,
      world_mesh_instances: 968,
      world_records: 735,
      world_shapes: 467,
      world_static_bodies: 466,
      world_surfaces: 983,
      world_topology_scope: PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE,
      // Current whole-world integration includes accepted B1 returns; D2 capture/component identities stay frozen.
      world_triangles: 71156,
    },
    ownership_contract: {
      decorative_collision_triangles: 0,
      decorative_navigation_nodes: 0,
      decorative_relief_triangles: 420,
      live_ownership_signature: D2_1439_OWNERSHIP_SIGNATURE,
      navigation_owner_count: 0,
      roof_collision_triangles: 10,
      roof_is_wall_spray_receiver: false,
      roof_world_solid_landing: true,
      shape_count: 3,
      spray_owner_count: 1,
      structural_owner_count: 2,
      wall_collision_triangles: 92,
      eligible_exterior_collision_triangles: 62,
      noneligible_closed_recess_collision_triangles: 30,
      wall_shape_order: ["eligible_exterior", "noneligible_closed_recess"],
      closed_recess_render_layer: 1,
      wall_decal_cull_mask: 2,
      wall_is_sole_spray_receiver: true,
    },
    replacement_contract: {
      actual_supplied_chunk_pair_required: true,
      fallback_allowed: false,
      generic_stack_allowed: false,
      mapped_public_run_indices: [...D2_1439_MAPPED_RUNS],
      partial_pair_allowed: false,
      protected_run_indices: [...D2_1439_PROTECTED_RUNS],
      roof_object_key: D2_1439_ROOF,
      source_key: D2_1439_SOURCE,
      wall_object_key: D2_1439_WALL,
    },
    schema_version: "ti.d2-1439-production-live-parity/1",
    truth_boundary: {
      as_built_fidelity_claimed: false,
      capture_time_candidate_promoted: false,
      capture_time_recognition_credit: false,
      game_distinctive_claimed: false,
      reference_pixels_packaged: false,
      receiver_complete_inferred_from_art: false,
      unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference: true,
      unobserved_sides_protected: true,
    },
  };
}

function d21444BehaviorContract() {
  return {
  "acceptance_contract": {
    "accepted_physical_unit_id": "physical-building:w95934117",
    "capture_time_recognition_metric": "9/213",
    "evidence_manifest_sha256": "9f1101abb3e4d6ac54f27a8a6db7d72ccd098721d0f59e8a6f72a6aa4c1293ef",
    "evidence_tree_sha256": "6872fe9f286370de3ab11ce27124583689a7fa0c4992bb4de4f2b9e8e1073003",
    "independent_live_review_receipt_sha256": "89c301ccdf5d02b71c5f4d79eacfee55521440edfbe2c6d780cd7c1d059d72c7",
    "mechanical_review_receipt_sha256": "7e62e914074646e438bc7c88a1f15fbc71eb40bfa00a0b04acf20e22e319c205",
    "motion_telemetry_manifest_sha256": "b569a5dc8b72c99c873a85c4fbc49b701ba72647a0299a4f8e7b0ff06b7309bc",
    "numerator_effect": 1,
    "package_verification_receipt_sha256": "b738e35d58ef6e75d0c4d98ae32d6157532703984fd48730281629211fe355a4",
    "reference_recognizable": true,
    "visual_motion_manifest_sha256": "327d9980de0798d7412ea691bd656f278a5e04da383c24fdb1cb272305b29e38",
    "wall_and_roof_are_one_physical_unit": true
  },
  "geometry_contract": {
    "canonical_roof_record_sha256": "0119a96ef2f8baf3e7a66a3db952cfd34930490b86dd25bf3693472728dadae1",
    "canonical_wall_record_sha256": "5a872a7e700aec63a2c276bb28c341e3f501ac8122f51267b05fb8a620d15950",
    "horizontal_source_footprint_preserved": true,
    "topology_delta_mesh_instances": 9,
    "topology_delta_records": 0,
    "topology_delta_shapes": 1,
    "topology_delta_static_bodies": 0,
    "topology_delta_surfaces": 9,
    "topology_delta_triangles": 672,
    "visual_geometry_signature": "1dba8f84003a0818c2ddb91504f41c3437a63fe0856ade70d1c194ca1be8d141",
    "visual_mesh_instances": 11,
    "visual_surfaces": 11,
    "visual_triangles": 726,
    "world_mesh_instances": 977,
    "world_records": 735,
    "world_shapes": 468,
    "world_static_bodies": 466,
    "world_surfaces": 992,
    "world_topology_scope": "pre_d5_batch_integration_live_parity",
    "world_triangles": 71828
  },
  "ownership_contract": {
    "closed_recess_render_layer": 1,
    "decorative_collision_triangles": 0,
    "decorative_navigation_nodes": 0,
    "decorative_relief_triangles": 612,
    "eligible_exterior_collision_triangles": 64,
    "live_ownership_signature": "979910c4d53486b86db04cdf04528789f668a01c41dc27114e481c843b91b92d",
    "navigation_owner_count": 0,
    "noneligible_closed_recess_collision_triangles": 40,
    "roof_collision_triangles": 10,
    "roof_is_wall_spray_receiver": false,
    "roof_world_solid_landing": true,
    "shape_count": 3,
    "spray_owner_count": 1,
    "structural_owner_count": 2,
    "wall_collision_triangles": 104,
    "wall_decal_cull_mask": 2,
    "wall_is_sole_spray_receiver": true,
    "wall_shape_order": [
      "eligible_exterior",
      "noneligible_closed_recess"
    ]
  },
  "replacement_contract": {
    "actual_supplied_chunk_pair_required": true,
    "fallback_allowed": false,
    "generic_stack_allowed": false,
    "mapped_public_run_indices": [
      8,
      9,
      11,
      12,
      15,
      16,
      17
    ],
    "partial_pair_allowed": false,
    "protected_run_indices": [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      10,
      13,
      14,
      18,
      19,
      20,
      21
    ],
    "roof_object_key": "building:w95934117:roof",
    "source_key": "w95934117",
    "wall_object_key": "building:w95934117:wall"
  },
  "schema_version": "ti.d2-1444-production-live-parity/1",
  "truth_boundary": {
    "as_built_fidelity_claimed": false,
    "capture_time_candidate_promoted": false,
    "capture_time_recognition_credit": false,
    "game_distinctive_claimed": false,
    "receiver_complete_inferred_from_art": false,
    "reference_pixels_packaged": false,
    "unobserved_sides_protected": true,
    "unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference": true
  }
};
}

function activeRecognitionAuthority(receiverKey, units) {
  const expectedUnitId = ACTIVE_ADAPTER_UNIT_BY_RECEIVER[receiverKey];
  invariant(expectedUnitId != null, `Active adapter receiver has no physical-unit recognition authority mapping: ${receiverKey}`);
  const matches = units.filter((unit) => unit.receiver_keys.includes(receiverKey));
  invariant(matches.length === 1 && matches[0].unit_id === expectedUnitId, `Active adapter receiver does not map to its exact physical-unit recognition authority: ${receiverKey}`);
  return {
    recognition_acceptance_authority: ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY,
    recognition_acceptance_status: matches[0].claim_status.reference_recognizable,
    review_status_scope: ACTIVE_REVIEW_STATUS_SCOPE,
  };
}

function deriveActiveRuntimeAdapterSeeds(inputs, units) {
  validateCurrentWorldBuilderDispatch(inputs);
  validateActiveHeroDispatch(inputs);
  validateActiveBuilding3Dispatch(inputs);
  validateActiveIsleHouseDispatch(inputs);
  validateActiveNavyChapelDispatch(inputs);
  validateActiveD1B201Dispatch(inputs);
  validateActiveD1B225Dispatch(inputs);
  validateActiveD21441Dispatch(inputs);
  validateActiveD21439Dispatch(inputs);
  validateActiveD21444Dispatch(inputs);
  validateD5BatchAuthority(inputs);
  const shared = {
    content_classification: "active_target_specific_hero_replacement",
    review_status: inputs.runtimeContracts.heroConfig.truth_boundary.visual_review_status,
    runtime_adapter_path: BUILDING_1_HERO_ADAPTER_PATH,
    runtime_asset_paths: [...building1HeroMaterialPaths(inputs), BUILDING_1_PUBLIC_FRONT_CONFIG_PATH].sort(),
    runtime_config_path: BUILDING_1_HERO_CONFIG_PATH,
    runtime_dispatch_path: WORLD_CHUNK_BUILDER_PATH,
    whole_building_recognizability_imported: false,
  };
  return [
    {
      ...shared,
      adapter_id: activeAdapterId(BUILDING_1_WALL),
      receiver_key: BUILDING_1_WALL,
      source_key: BUILDING_1_SOURCE,
    },
    {
      ...shared,
      adapter_id: activeAdapterId(BUILDING_1_TOWER_WALL),
      receiver_key: BUILDING_1_TOWER_WALL,
      source_key: BUILDING_1_TOWER_SOURCE,
    },
    {
      adapter_id: building3ActiveAdapterId(BUILDING_3_WALL),
      content_classification: "active_target_specific_hero_replacement",
      receiver_key: BUILDING_3_WALL,
      review_status: inputs.runtimeContracts.building3Config.truth_boundary.visual_review_status,
      runtime_adapter_path: BUILDING_3_MASSING_PATH,
      runtime_asset_paths: [...BUILDING_3_FACADE_ASSET_PATHS],
      runtime_config_path: BUILDING_3_CONFIG_PATH,
      runtime_dispatch_path: WORLD_CHUNK_BUILDER_PATH,
      source_key: BUILDING_3_SOURCE,
      whole_building_recognizability_imported: false,
    },
    {
      adapter_id: isleHouseActiveAdapterId(ISLE_HOUSE_LOW_WALL),
      content_classification: "active_target_specific_composite_part_replacement",
      receiver_key: ISLE_HOUSE_LOW_WALL,
      review_status: "independent_exact_current_live_pass",
      runtime_adapter_path: ISLE_HOUSE_LIVE_ADAPTER_PATH,
      runtime_asset_paths: [
        ISLE_HOUSE_REPAIR_FACTORY_PATH,
        ISLE_HOUSE_REVIEWED_FACTORY_PATH,
      ],
      runtime_config_path: ISLE_HOUSE_VARIANT_C_CONFIG_PATH,
      runtime_dispatch_path: WORLD_CHUNK_BUILDER_PATH,
      source_key: ISLE_HOUSE_LOW_SOURCE,
      whole_building_recognizability_imported: false,
    },
    {
      adapter_id: navyChapelActiveAdapterId(NAVY_CHAPEL_WALL),
      content_classification: "active_target_specific_paired_wall_roof_replacement",
      receiver_key: NAVY_CHAPEL_WALL,
      review_status: "independent_exact_current_live_pass",
      runtime_adapter_path: NAVY_CHAPEL_LIVE_ADAPTER_PATH,
      runtime_asset_paths: [...NAVY_CHAPEL_RUNTIME_ASSET_PATHS],
      runtime_config_path: NAVY_CHAPEL_CONFIG_PATH,
      runtime_dispatch_path: WORLD_CHUNK_BUILDER_PATH,
      source_key: NAVY_CHAPEL_SOURCE,
      whole_building_recognizability_imported: false,
    },
    {
      adapter_id: d1B201ActiveAdapterId(D1_B201_WALL),
      content_classification: "active_target_specific_receiver_host_partition_plus_render_only_attachment",
      receiver_key: D1_B201_WALL,
      review_status: "independent_exact_current_live_pass",
      runtime_adapter_path: D1_B201_LIVE_ADAPTER_PATH,
      runtime_asset_paths: [...D1_B201_RUNTIME_ASSET_PATHS],
      runtime_config_path: D1_B201_CONFIG_PATH,
      runtime_dispatch_path: WORLD_CHUNK_BUILDER_PATH,
      source_key: D1_B201_SOURCE,
      whole_building_recognizability_imported: false,
    },
    {
      adapter_id: d1B225ActiveAdapterId(D1_B225_WALL),
      content_classification: "active_target_specific_receiver_host_partition_plus_render_only_attachment",
      receiver_key: D1_B225_WALL,
      review_status: "independent_exact_current_live_pass",
      runtime_adapter_path: D1_B225_LIVE_ADAPTER_PATH,
      runtime_asset_paths: [...D1_B225_RUNTIME_ASSET_PATHS],
      runtime_config_path: D1_B225_CONFIG_PATH,
      runtime_dispatch_path: WORLD_CHUNK_BUILDER_PATH,
      source_key: D1_B225_SOURCE,
      whole_building_recognizability_imported: false,
    },
    {
      adapter_id: d21441ActiveAdapterId(D2_1441_WALL),
      content_classification: "active_target_specific_paired_wall_roof_replacement",
      receiver_key: D2_1441_WALL,
      review_status: "independent_exact_current_live_pass",
      runtime_adapter_path: D2_1441_LIVE_ADAPTER_PATH,
      runtime_asset_paths: [...D2_1441_RUNTIME_ASSET_PATHS],
      runtime_config_path: D2_1441_CONFIG_PATH,
      runtime_dispatch_path: WORLD_CHUNK_BUILDER_PATH,
      source_key: D2_1441_SOURCE,
      whole_building_recognizability_imported: false,
    },
    {
      adapter_id: d21439ActiveAdapterId(D2_1439_WALL),
      content_classification: "active_target_specific_paired_wall_roof_replacement",
      receiver_key: D2_1439_WALL,
      review_status: "independent_exact_current_live_pass",
      runtime_adapter_path: D2_1439_LIVE_ADAPTER_PATH,
      runtime_asset_paths: [...D2_1439_RUNTIME_ASSET_PATHS],
      runtime_config_path: D2_1439_CONFIG_PATH,
      runtime_dispatch_path: WORLD_CHUNK_BUILDER_PATH,
      source_key: D2_1439_SOURCE,
      whole_building_recognizability_imported: false,
    },
    {
      adapter_id: d21444ActiveAdapterId(D2_1444_WALL),
      content_classification: "active_target_specific_paired_wall_roof_replacement",
      receiver_key: D2_1444_WALL,
      review_status: "independent_exact_current_live_pass",
      runtime_adapter_path: D2_1444_LIVE_ADAPTER_PATH,
      runtime_asset_paths: [...D2_1444_RUNTIME_ASSET_PATHS],
      runtime_config_path: D2_1444_CONFIG_PATH,
      runtime_dispatch_path: WORLD_CHUNK_BUILDER_PATH,
      source_key: D2_1444_SOURCE,
      whole_building_recognizability_imported: false,
    },
    {
  "adapter_id": "active-adapter:d5-1308-live:building:w95934123:wall",
  "content_classification": "active_target_specific_paired_wall_roof_replacement",
  "receiver_key": "building:w95934123:wall",
  "review_status": "independent_exact_current_live_pass",
  "runtime_adapter_path": "game/scripts/world/facades/d5_1308_gateview_live_replacement.gd",
  "runtime_asset_paths": [
    "game/resources/facades/d5_1308_gateview_live_factory.json",
    "game/resources/facades/d5_1308_siding_marks.gdshader",
    "game/scripts/world/facades/d5_1308_gateview_live_factory.gd",
    "game/scripts/world/facades/site_12_housing_kit.gd",
    "game/resources/facades/d5_1308_lawn_tone.gdshader"
  ],
  "runtime_config_path": "game/resources/facades/d5_1308_gateview_live_replacement.json",
  "runtime_dispatch_path": "game/scripts/world/world_chunk_builder.gd",
  "source_key": "w95934123",
  "whole_building_recognizability_imported": false
},
    {
  "adapter_id": "active-adapter:d5-1394-live:building:w96215646:wall",
  "content_classification": "active_target_specific_paired_wall_roof_replacement",
  "receiver_key": "building:w96215646:wall",
  "review_status": "independent_exact_current_live_pass",
  "runtime_adapter_path": "game/scripts/world/facades/d5_1394_gateview_live_replacement.gd",
  "runtime_asset_paths": [
    "game/resources/facades/d5_1394_gateview_live_factory.json",
    "game/resources/facades/d5_1394_siding_marks.gdshader",
    "game/scripts/world/facades/d5_1394_gateview_live_factory.gd",
    "game/scripts/world/facades/site_12_housing_kit.gd",
    "game/resources/facades/d5_1394_lawn_tone.gdshader"
  ],
  "runtime_config_path": "game/resources/facades/d5_1394_gateview_live_replacement.json",
  "runtime_dispatch_path": "game/scripts/world/world_chunk_builder.gd",
  "source_key": "w96215646",
  "whole_building_recognizability_imported": false
},
    {
  "adapter_id": "active-adapter:d5-1317-live:building:w95934125:wall",
  "content_classification": "active_target_specific_paired_wall_roof_replacement",
  "receiver_key": "building:w95934125:wall",
  "review_status": "independent_exact_current_live_pass",
  "runtime_adapter_path": "game/scripts/world/facades/d5_1317_gateview_live_replacement.gd",
  "runtime_asset_paths": [
    "game/resources/facades/d5_1317_gateview_quality_study.json",
    "game/resources/facades/d5_1317_siding_marks.gdshader",
    "game/scripts/world/facades/d5_1317_gateview_live_factory.gd",
    "game/scripts/world/facades/site_12_housing_kit.gd",
    "game/resources/facades/d5_1317_quality_study_geometry.json",
    "game/resources/facades/d5_1317_surface_tone.gdshader"
  ],
  "runtime_config_path": "game/resources/facades/d5_1317_gateview_live_replacement.json",
  "runtime_dispatch_path": "game/scripts/world/world_chunk_builder.gd",
  "source_key": "w95934125",
  "whole_building_recognizability_imported": false
},
    {
  "adapter_id": "active-adapter:fire-station48-live:building:w764313741:wall",
  "content_classification": "active_target_specific_paired_wall_roof_replacement",
  "receiver_key": "building:w764313741:wall",
  "review_status": "independent_exact_current_live_pass",
  "runtime_adapter_path": "game/scripts/world/facades/fire_station48_live_replacement.gd",
  "runtime_asset_paths": [
    "game/resources/facades/fire_station48_quality_study.json",
    "game/resources/facades/fire_station48_upper_cladding.gdshader",
    "game/scripts/world/facades/fire_station48_live_factory.gd",
    "game/scripts/world/facades/site_12_housing_kit.gd",
    "game/resources/facades/fire_station48_study_geometry.json"
  ],
  "runtime_config_path": "game/resources/facades/fire_station48_live_replacement.json",
  "runtime_dispatch_path": "game/scripts/world/world_chunk_builder.gd",
  "source_key": "w764313741",
  "whole_building_recognizability_imported": false
},
  ].map((seed) => ({
    ...seed,
    ...activeRecognitionAuthority(seed.receiver_key, units),
  })).sort((left, right) => left.receiver_key.localeCompare(right.receiver_key));
}

function buildSeedCatalog(inputs) {
  const units = deriveUnitSeeds(inputs.inventory);
  const legacyAdapters = deriveLegacyAdapterSeeds(inputs.inventory);
  const activeRuntimeAdapters = deriveActiveRuntimeAdapterSeeds(inputs, units);
  const adapterByReceiver = new Map(legacyAdapters.map((adapter) => [adapter.receiver_key, adapter.adapter_id]));
  for (const unit of units) {
    unit.legacy_adapter_ids = unit.receiver_keys
      .filter((receiverKey) => adapterByReceiver.has(receiverKey))
      .map((receiverKey) => adapterByReceiver.get(receiverKey));
  }
  return {
    $schema: CATALOG_SCHEMA_REFERENCE,
    active_runtime_adapters: activeRuntimeAdapters,
    catalog_id: CATALOG_ID,
    capture_contracts: [],
    checked_date: CHECKED_DATE,
    claim_vocabulary: CLAIM_VOCABULARY,
    compiler_contract: CATALOG_COMPILER_CONTRACT,
    expected_counts: EXPECTED,
    identity_evidence_records: [],
    legacy_adapters: legacyAdapters,
    schema_version: CATALOG_SCHEMA,
    source_contract: {
      generated_content_sha256: inputs.manifest.content_sha256,
      generated_manifest_schema_version: inputs.manifest.schema_version,
      generated_manifest_sha256: inputs.manifestSha256,
      inventory_schema_version: inputs.inventory.schema_version,
      inventory_sha256: inputs.inventorySha256,
    },
    unit_seed: {
      immutable_input: true,
      strategy: SEED_STRATEGY,
    },
    units,
  };
}

function validateCatalog(catalog, inputs, derivedUnits, receiverByKey) {
  assertJsonSchema(catalog, inputs.catalogSchema, PATHS.catalog);
  assertExactKeys(catalog, [
    "$schema",
    "active_runtime_adapters",
    "catalog_id",
    "capture_contracts",
    "checked_date",
    "claim_vocabulary",
    "compiler_contract",
    "expected_counts",
    "identity_evidence_records",
    "legacy_adapters",
    "schema_version",
    "source_contract",
    "unit_seed",
    "units",
  ], "Facade recognition catalog");
  invariant(catalog.$schema === CATALOG_SCHEMA_REFERENCE, "Catalog schema reference drifted");
  invariant(catalog.schema_version === CATALOG_SCHEMA, "Catalog schema version drifted");
  invariant(catalog.catalog_id === CATALOG_ID, "Catalog identity drifted");
  invariant(/^\d{4}-\d{2}-\d{2}$/u.test(catalog.checked_date), "Catalog checked_date is invalid");
  invariant(Array.isArray(catalog.capture_contracts), "Catalog capture_contracts must be an array");
  invariant(Array.isArray(catalog.active_runtime_adapters) && catalog.active_runtime_adapters.length === EXPECTED.active_runtime_adapter_receivers, "Catalog active runtime adapter count drifted");
  invariant(Array.isArray(catalog.identity_evidence_records), "Catalog identity_evidence_records must be an array");
  invariant(equalStable(catalog.claim_vocabulary, CLAIM_VOCABULARY), "Catalog claim vocabulary drifted");
  invariant(equalStable(catalog.compiler_contract, CATALOG_COMPILER_CONTRACT), "Catalog compiler compatibility contract drifted or requests an unsupported future version");
  invariant(equalStable(catalog.expected_counts, EXPECTED), "Catalog expected counts drifted");
  invariant(equalStable(catalog.unit_seed, { immutable_input: true, strategy: SEED_STRATEGY }), "Catalog unit seed contract drifted");
  invariant(equalStable(catalog.source_contract, {
    generated_content_sha256: inputs.manifest.content_sha256,
    generated_manifest_schema_version: inputs.manifest.schema_version,
    generated_manifest_sha256: inputs.manifestSha256,
    inventory_schema_version: inputs.inventory.schema_version,
    inventory_sha256: inputs.inventorySha256,
  }), "Catalog immutable source contract drifted");
  invariant(Array.isArray(catalog.units) && catalog.units.length === EXPECTED.recognition_units, "Catalog must contain exactly 213 recognition units");
  invariant(Array.isArray(catalog.legacy_adapters) && catalog.legacy_adapters.length === EXPECTED.legacy_adapter_receivers, "Catalog legacy adapter count drifted");

  const derivedById = new Map(derivedUnits.map((unit) => [unit.unit_id, unit]));
  const inventoryByKey = inventoryObjectsByKey(inputs.inventory);
  const adapterById = new Map(catalog.legacy_adapters.map((adapter) => [adapter.adapter_id, adapter]));
  const expectedActiveAdapters = deriveActiveRuntimeAdapterSeeds(inputs, catalog.units);
  const captureByUnit = new Map(catalog.capture_contracts.map((capture) => [capture.unit_id, capture]));
  assertUnique(catalog.units.map((unit) => unit.unit_id), "Catalog unit IDs");
  assertUnique(catalog.legacy_adapters.map((adapter) => adapter.adapter_id), "Catalog adapter IDs");
  assertUnique(catalog.legacy_adapters.map((adapter) => adapter.receiver_key), "Catalog adapter receivers");
  assertUnique(catalog.active_runtime_adapters.map((adapter) => adapter.adapter_id), "Catalog active runtime adapter IDs");
  assertUnique(catalog.active_runtime_adapters.map((adapter) => adapter.receiver_key), "Catalog active runtime adapter receivers");
  assertUnique([
    ...catalog.legacy_adapters.map((adapter) => adapter.receiver_key),
    ...catalog.active_runtime_adapters.map((adapter) => adapter.receiver_key),
  ], "Catalog combined runtime adapter receivers");
  assertUnique(catalog.capture_contracts.map((capture) => capture.unit_id), "Catalog capture-contract units");
  assertUnique(catalog.identity_evidence_records.map((record) => record.assertion_id), "Catalog identity assertion IDs");
  assertUnique(catalog.identity_evidence_records.map((record) => `${record.unit_id}/${record.frozen_field}/${record.evidence_class}`), "Catalog identity assertion unit/field/classes");

  for (const capture of catalog.capture_contracts) {
    validateCaptureContract(capture, derivedById);
  }
  for (const record of catalog.identity_evidence_records) {
    validateIdentityEvidenceRecord(record, derivedById, inventoryByKey);
  }
  invariant(equalStable(catalog.active_runtime_adapters, expectedActiveAdapters), "Catalog active Building 1/Building 3 hero adapters drifted from exact-current runtime dispatch");

  for (const adapter of catalog.legacy_adapters) {
    assertExactKeys(adapter, ["adapter_id", "import_basis", "receiver_key", "source_key", "whole_building_recognizability_imported"], `Legacy adapter ${adapter.adapter_id}`);
    invariant(adapter.adapter_id === adapterId(adapter.receiver_key), `${adapter.adapter_id} is not derived from its receiver`);
    invariant(adapter.import_basis === "inventory_accepted_target_specific_runtime_attachment", `${adapter.adapter_id} import basis drifted`);
    invariant(adapter.whole_building_recognizability_imported === false, `${adapter.adapter_id} improperly imports whole-building recognizability`);
    invariant(receiverByKey.has(adapter.receiver_key), `${adapter.adapter_id} receiver is absent from generated data`);
  }

  for (const unit of catalog.units) {
    assertExactKeys(unit, [
      "acceptance_records",
      "anchor_source_key",
      "claim_status",
      "human_dependency_ids",
      "identity",
      "legacy_adapter_ids",
      "protected_scopes",
      "receiver_keys",
      "recognition_cues",
      "reference_records",
      "reference_state",
      "source_records",
      "unit_id",
      "unit_kind",
    ], `Catalog unit ${unit.unit_id}`);
    const expected = derivedById.get(unit.unit_id);
    invariant(expected != null, `Catalog contains unknown unit ${unit.unit_id}`);
    for (const key of ["anchor_source_key", "identity", "receiver_keys", "source_records", "unit_kind"]) {
      invariant(equalStable(unit[key], expected[key]), `${unit.unit_id}.${key} drifted from immutable inventory`);
    }
    assertExactKeys(unit.claim_status, ["as_built_fidelity", "game_distinctive", "receiver_complete", "reference_recognizable"], `${unit.unit_id}.claim_status`);
    invariant(unit.claim_status.receiver_complete === "verified", `${unit.unit_id} must fail closed unless receiver-complete`);
    invariant(["not_evaluated", "accepted", "rejected"].includes(unit.claim_status.game_distinctive), `${unit.unit_id} has invalid game-distinctive status`);
    invariant(["not_evaluated", "accepted", "rejected", "blocked"].includes(unit.claim_status.reference_recognizable), `${unit.unit_id} has invalid reference-recognizable status`);
    invariant(["unclaimed", "limited", "claimed"].includes(unit.claim_status.as_built_fidelity), `${unit.unit_id} has invalid as-built status`);
    invariant(["identity_or_reference_research_required", "reference_research_unassessed", "reference_ready", "reference_blocked"].includes(unit.reference_state), `${unit.unit_id} has invalid reference state`);
    for (const key of ["acceptance_records", "human_dependency_ids", "legacy_adapter_ids", "protected_scopes", "recognition_cues", "reference_records"]) {
      invariant(Array.isArray(unit[key]), `${unit.unit_id}.${key} must be an array`);
    }
    assertUnique(unit.receiver_keys, `${unit.unit_id} receivers`);
    assertUnique(unit.legacy_adapter_ids, `${unit.unit_id} legacy adapters`);
    invariant(unit.receiver_keys.every((receiverKey) => receiverByKey.has(receiverKey)), `${unit.unit_id} references a missing receiver`);
    invariant(unit.legacy_adapter_ids.every((id) => adapterById.has(id)), `${unit.unit_id} references a missing legacy adapter`);
    const expectedAdapterIds = unit.receiver_keys
      .map((receiverKey) => adapterId(receiverKey))
      .filter((id) => adapterById.has(id));
    invariant(equalStable(unit.legacy_adapter_ids, expectedAdapterIds), `${unit.unit_id} legacy adapter membership drifted`);
    validateAuthoredRecognitionState(unit, receiverByKey, captureByUnit.get(unit.unit_id));
  }

  for (const adapter of catalog.active_runtime_adapters) {
    const expectedUnitId = ACTIVE_ADAPTER_UNIT_BY_RECEIVER[adapter.receiver_key];
    const unit = catalog.units.find((candidate) => candidate.unit_id === expectedUnitId);
    invariant(unit != null && unit.receiver_keys.includes(adapter.receiver_key), `${adapter.adapter_id} does not cross-link to its exact physical recognition unit`);
    invariant(adapter.review_status === ACTIVE_ADAPTER_REVIEW_STATUS_BY_RECEIVER[adapter.receiver_key], `${adapter.adapter_id} review status is not an exact allowed provenance status`);
    invariant(adapter.review_status_scope === ACTIVE_REVIEW_STATUS_SCOPE, `${adapter.adapter_id} review status scope does not isolate runtime-asset original-detail provenance`);
    invariant(adapter.recognition_acceptance_authority === ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, `${adapter.adapter_id} recognition authority does not belong to the physical-unit claim and independent receipt`);
    invariant(adapter.recognition_acceptance_status === unit.claim_status.reference_recognizable && adapter.recognition_acceptance_status === "accepted", `${adapter.adapter_id} recognition acceptance status does not equal its accepted physical-unit claim`);
    invariant(unit.acceptance_records.some((record) => record.review_kind === "independent_reference_recognition" && record.status === "accept"), `${adapter.adapter_id} physical recognition unit lacks an independent acceptance receipt`);
  }

  invariant(equalStable([...derivedById.keys()].sort(), catalog.units.map((unit) => unit.unit_id).sort()), "Catalog does not exactly cover derived recognition units");
  const sourceMembership = catalog.units.flatMap((unit) => unit.source_records.map((source) => source.source_key));
  const receiverMembership = catalog.units.flatMap((unit) => unit.receiver_keys);
  assertUnique(sourceMembership, "Catalog source membership");
  assertUnique(receiverMembership, "Catalog receiver membership");
  invariant(sourceMembership.length === EXPECTED.source_records, "Catalog source membership count drifted");
  invariant(receiverMembership.length === EXPECTED.direct_wall_receivers, "Catalog receiver membership count drifted");
  const acceptedReferenceUnitIds = catalog.units
    .filter((unit) => unit.claim_status.reference_recognizable === "accepted")
    .map((unit) => unit.unit_id)
    .sort();
  invariant(equalStable(acceptedReferenceUnitIds, [...ACCEPTED_REFERENCE_UNIT_IDS].sort()), "Catalog reference-recognizable rollup must equal the independently accepted physical-unit list");
  invariant(!catalog.units.some((unit) => ISLE_HOUSE_PARTS.map(unitId).includes(unit.unit_id)), "Isle House receiver source records must never become recognition units");
  const isleHouseUnit = catalog.units.find((unit) => unit.unit_id === ISLE_HOUSE_UNIT_ID);
  invariant(isleHouseUnit?.unit_kind === "composite_building" && isleHouseUnit.claim_status.reference_recognizable === "accepted", "Isle House acceptance must belong to its composite physical-building parent");
  const navyChapelUnit = catalog.units.find((unit) => unit.unit_id === unitId(NAVY_CHAPEL_SOURCE));
  invariant(navyChapelUnit?.unit_kind === "standalone_building" && navyChapelUnit.claim_status.reference_recognizable === "accepted" && navyChapelUnit.receiver_keys.length === 1, "Navy Chapel wall/roof acceptance must roll up to one standalone physical-building unit");
  const d1B225Unit = catalog.units.find((unit) => unit.unit_id === unitId(D1_B225_SOURCE));
  invariant(d1B225Unit?.unit_kind === "standalone_building" && d1B225Unit.claim_status.reference_recognizable === "accepted" && d1B225Unit.receiver_keys.length === 1, "D1 B225 acceptance must roll up to one standalone physical-building unit");
  invariant(d1B225Unit.acceptance_records.length === 1 && d1B225Unit.acceptance_records[0].evidence_tree_sha256 === D1_B225_EVIDENCE_TREE_SHA256 && d1B225Unit.acceptance_records[0].capture_time_recognition_metric === "7/213" && d1B225Unit.acceptance_records[0].numerator_effect === 1, "D1 B225 physical-unit acceptance does not bind the exact frozen production tree and +1 transition");
  const d21441Unit = catalog.units.find((unit) => unit.unit_id === unitId(D2_1441_SOURCE));
  invariant(d21441Unit?.unit_kind === "standalone_building" && d21441Unit.claim_status.reference_recognizable === "accepted" && d21441Unit.receiver_keys.length === 1, "D2 1441 acceptance must roll up to one standalone physical-building unit");
  invariant(d21441Unit.acceptance_records.length === 1 && equalStable(d21441Unit.acceptance_records[0], d21441AcceptanceRecord()), "D2 1441 physical-unit acceptance must be exactly one seven-artifact-bound +1 record");
  const d21439Unit = catalog.units.find((unit) => unit.unit_id === unitId(D2_1439_SOURCE));
  const d21444Unit = catalog.units.find((unit) => unit.unit_id === unitId(D2_1444_SOURCE));
  invariant(d21439Unit?.unit_kind === "standalone_building" && d21439Unit.claim_status.reference_recognizable === "accepted" && d21439Unit.receiver_keys.length === 1, "D2 1439 acceptance must roll up to one standalone physical-building unit");
  invariant(d21444Unit?.unit_kind === "standalone_building" && d21444Unit.claim_status.reference_recognizable === "accepted" && d21444Unit.receiver_keys.length === 1, "D2 1444 acceptance must roll up to one standalone physical-building unit");
  invariant(d21439Unit.acceptance_records.length === 1 && equalStable(d21439Unit.acceptance_records[0], d21439AcceptanceRecord()), "D2 1439 physical-unit acceptance must be exactly one seven-artifact-bound +1 record");
  invariant(d21444Unit.acceptance_records.length === 1 && equalStable(d21444Unit.acceptance_records[0], d21444AcceptanceRecord()), "D2 1444 physical-unit acceptance must be exactly one seven-artifact-bound +1 record");
}

function frozenIdentityValue(object, frozenField) {
  const tagPrefix = "source.tags.";
  if (frozenField.startsWith(tagPrefix)) {
    return object.source.tags?.[frozenField.slice(tagPrefix.length)] ?? null;
  }
  if (frozenField === "identity.canonical_name") return object.identity.canonical_name ?? null;
  if (frozenField === "identity.address.formatted") return object.identity.address?.formatted ?? null;
  throw new Error(`Unsupported frozen identity field ${frozenField}`);
}

function validateIdentityEvidenceRecord(record, derivedById, inventoryByKey) {
  assertExactKeys(record, [
    "assertion_id",
    "checked_date",
    "currentness_claimed",
    "evidence_class",
    "evidenced_value",
    "frozen_field",
    "frozen_value",
    "primary_source_locator",
    "research_packet_path",
    "runtime_visibility",
    "unit_id",
  ], `Identity evidence ${record.assertion_id}`);
  const unit = derivedById.get(record.unit_id);
  invariant(unit != null, `${record.assertion_id} targets an unknown recognition unit`);
  invariant(/^identity-assertion:/u.test(record.assertion_id), `${record.assertion_id} has an invalid assertion ID`);
  invariant(/^\d{4}-\d{2}-\d{2}$/u.test(record.checked_date), `${record.assertion_id} has an invalid checked date`);
  invariant(["authoritative_correction", "authoritative_current_identity", "reference_identity_context"].includes(record.evidence_class), `${record.assertion_id} has an invalid evidence class`);
  invariant(typeof record.evidenced_value === "string" && record.evidenced_value.length > 0, `${record.assertion_id} has an empty evidenced value`);
  invariant(typeof record.frozen_field === "string" && record.frozen_field.length > 0, `${record.assertion_id} has an invalid frozen field`);
  invariant(record.frozen_value == null || (typeof record.frozen_value === "string" && record.frozen_value.length > 0), `${record.assertion_id} has an invalid frozen value`);
  invariant(typeof record.primary_source_locator === "string" && /^https:\/\//u.test(record.primary_source_locator), `${record.assertion_id} must cite an HTTPS primary source`);
  invariant(typeof record.research_packet_path === "string" && record.research_packet_path.startsWith("discovery/facades/"), `${record.assertion_id} research packet must remain source-only`);
  invariant(existsSync(absolute(record.research_packet_path)) && statSync(absolute(record.research_packet_path)).isFile(), `${record.assertion_id} research packet is missing`);
  invariant(["summary_only", "source_only"].includes(record.runtime_visibility), `${record.assertion_id} has invalid runtime visibility`);
  invariant(typeof record.currentness_claimed === "boolean", `${record.assertion_id} must state currentness explicitly`);
  const anchor = inventoryByKey.get(unit.anchor_source_key);
  invariant(anchor != null, `${record.assertion_id} cannot resolve its frozen anchor`);
  const observedFrozenValue = frozenIdentityValue(anchor, record.frozen_field);
  invariant(equalStable(record.frozen_value, observedFrozenValue), `${record.assertion_id} frozen value does not exactly match immutable inventory`);
  if (record.evidence_class === "authoritative_correction") {
    invariant(record.frozen_value != null && record.evidenced_value !== record.frozen_value, `${record.assertion_id} does not correct a frozen value`);
    invariant(record.currentness_claimed === false, `${record.assertion_id} correction must not silently make a broad currentness claim`);
  }
  if (record.evidence_class === "authoritative_current_identity") {
    invariant(record.currentness_claimed === true, `${record.assertion_id} current-identity evidence must explicitly claim currentness`);
  }
  if (record.evidence_class === "reference_identity_context") {
    invariant(record.currentness_claimed === false, `${record.assertion_id} context evidence cannot claim currentness`);
  }
}

function validateCaptureContract(capture, derivedById) {
  assertExactKeys(capture, [
    "alternate_pose",
    "ordinary_third_person_required",
    "primary_pose",
    "required_cue_ids",
    "status",
    "unit_id",
  ], `Capture contract ${capture.unit_id}`);
  invariant(derivedById.has(capture.unit_id), `Capture contract targets unknown unit ${capture.unit_id}`);
  invariant(capture.ordinary_third_person_required === true, `${capture.unit_id} capture contract must use ordinary third person`);
  invariant(["configured", "blocked"].includes(capture.status), `${capture.unit_id} capture status is invalid`);
  invariant(Array.isArray(capture.required_cue_ids), `${capture.unit_id} required capture cues must be an array`);
  assertUnique(capture.required_cue_ids, `${capture.unit_id} required capture cues`);
  if (capture.status === "configured") {
    validateCapturePose(capture.primary_pose, `${capture.unit_id} primary pose`);
    validateCapturePose(capture.alternate_pose, `${capture.unit_id} alternate pose`);
  } else {
    invariant(capture.primary_pose == null && capture.alternate_pose == null, `${capture.unit_id} blocked capture contract cannot contain poses`);
  }
}

function validateCapturePose(pose, label) {
  assertExactKeys(pose, ["aim_target_m", "camera_position_m", "fov_degrees", "player_position_m"], label);
  for (const key of ["aim_target_m", "camera_position_m", "player_position_m"]) {
    invariant(Array.isArray(pose[key]) && pose[key].length === 3 && pose[key].every(Number.isFinite), `${label}.${key} must be a finite Vector3`);
  }
  invariant(Number.isFinite(pose.fov_degrees) && pose.fov_degrees >= 35 && pose.fov_degrees <= 90, `${label}.fov_degrees is outside ordinary-camera bounds`);
}

function d21441AcceptanceRecord() {
  return {
    capture_time_recognition_metric: "8/213",
    evidence_manifest_sha256: D2_1441_EVIDENCE_MANIFEST_SHA256,
    evidence_tree_sha256: D2_1441_EVIDENCE_TREE_SHA256,
    mechanical_review_receipt_sha256: D2_1441_MECHANICAL_REVIEW_RECEIPT_SHA256,
    motion_telemetry_manifest_sha256: D2_1441_MOTION_TELEMETRY_MANIFEST_SHA256,
    numerator_effect: 1,
    package_verification_receipt_sha256: D2_1441_PACKAGE_VERIFICATION_RECEIPT_SHA256,
    review_id: D2_1441_REVIEW_ID,
    review_kind: "independent_reference_recognition",
    review_receipt_sha256: D2_1441_VISUAL_REVIEW_RECEIPT_SHA256,
    status: "accept",
    visual_motion_manifest_sha256: D2_1441_VISUAL_MOTION_MANIFEST_SHA256,
  };
}

function d21439AcceptanceRecord() {
  return {
    capture_time_recognition_metric: "9/213",
    evidence_manifest_sha256: D2_1439_EVIDENCE_MANIFEST_SHA256,
    evidence_tree_sha256: D2_1439_EVIDENCE_TREE_SHA256,
    mechanical_review_receipt_sha256: D2_1439_MECHANICAL_REVIEW_RECEIPT_SHA256,
    motion_telemetry_manifest_sha256: D2_1439_MOTION_TELEMETRY_MANIFEST_SHA256,
    numerator_effect: 1,
    package_verification_receipt_sha256: D2_1439_PACKAGE_VERIFICATION_RECEIPT_SHA256,
    review_id: D2_1439_REVIEW_ID,
    review_kind: "independent_reference_recognition",
    review_receipt_sha256: D2_1439_VISUAL_REVIEW_RECEIPT_SHA256,
    status: "accept",
    visual_motion_manifest_sha256: D2_1439_VISUAL_MOTION_MANIFEST_SHA256,
  };
}

function validateD5BatchAuthority(inputs) {
  for (const d of D5_BATCH_ACCEPTED) {
    const label = `D5 ${d.number}`;
    for (const [kind, path] of Object.entries(d.files)) invariant(sha256File(absolute(path)) === d.hashes[kind], `${label} ${kind} source drifted`);
    invariant(equalStable(readJson(d.files.config), d.config), `${label} exact run/pair/terrain configuration drifted`);
    invariant(sha256File(absolute(d.source_chunk?.path ?? `generated/world/chunks/${d.config.chunk_id}.json`)) === (d.source_chunk?.sha256 ?? d.config.chunk_sha256), `${label} terrain/source chunk drifted`);
    const receipt = d.receipt;
    const fields = {evidence_manifest_path:"evidence_manifest_sha256", motion_telemetry_manifest_path:"motion_telemetry_manifest_sha256", visual_motion_manifest_path:"visual_motion_manifest_sha256", package_verification_receipt_path:"package_verification_receipt_sha256", mechanical_review_receipt_path:"mechanical_review_receipt_sha256", review_path:"review_receipt_sha256"};
    for (const [pathKey, hashKey] of Object.entries(fields)) invariant(sha256File(absolute(receipt[pathKey])) === receipt[hashKey], `${label} ${hashKey} artifact missing or drifted`);
    invariant(sha256File(absolute(receipt.evidence_tree_path)) === d.tree_document_sha256, `${label} tree document drifted`);
    const tree = readJson(receipt.evidence_tree_path);
    invariant(tree.tree_sha256 === receipt.evidence_tree_sha256 && tree.files.length === d.image_count, `${label} image-tree digest/count drifted`);
    for (const file of tree.files) invariant(sha256File(absolute(`${dirname(receipt.evidence_tree_path)}/${file.path}`)) === file.sha256, `${label} native image bytes drifted: ${file.path}`);
    const review = readJson(receipt.review_path);
    const six = Object.fromEntries(Object.entries(d.acceptance).filter(([key]) => key.endsWith("_sha256") && key !== "review_receipt_sha256"));
    invariant(review.decision === "PASS" && review.physical_unit_id === d.unit_id && equalStable(review.acceptance_bindings, six) && review.evidence_tree_document_sha256 === d.tree_document_sha256, `${label} independent seventh attestation binding drifted`);
    const pkg = readJson(receipt.package_verification_receipt_path);
    invariant(pkg.owner_decision === "PASS" && pkg.independent_exact_app_decision === "PASS" && pkg.independent_exact_app_review_pending === false && pkg.physical_unit_id === d.unit_id && pkg.candidate_authority === d.acceptance.capture_time_recognition_metric && pkg.truth_boundary.credit_granted === false && pkg.truth_boundary.authority_mutated === false, `${label} historical candidate package truth drifted`);
    if (d.number === "station48") {
      invariant(pkg.truth_boundary.new_unit_candidate === true && pkg.truth_boundary.prospective_numerator_effect_after_separate_acceptance === 1 && pkg.independent_review.sha256 === "721e572380ae11cda759c8c6105b8a596e9383df092a6dcc654d2e24e7214996" && pkg.terminal_slot_releases.some((r) => r.sha256 === "3de79cc56e40d90f6ce24b8d886567d1d49501bfeb754f5ec6642dc5a2b4d5e2"), `${label} independent candidate package/terminal gate drifted`);
      invariant(pkg.signature_privacy_binding.sha256 === "8d812f268a275ab854d483363d21711c22acb47732ae597329aaba8484b6a7d8" && pkg.pck_sha256 === "10797243d362f4005755f6ab43e08c5ed467959a11e0beaf2cdcb8b287f42edd", `${label} accepted candidate app drifted`);
    } else if (d.number === "1317") {
      invariant(pkg.truth_boundary.new_unit_candidate === true && pkg.truth_boundary.prospective_numerator_effect_after_separate_acceptance === 1 && pkg.independent_review.sha256 === "fb4f28ce1a9b3ca433001174052d48cb68b9162042f07e6e764feeb14a6734fa" && pkg.terminal_slot_releases.some((r) => r.sha256 === "b474345fdca131d2dce3edba134ae9db81a8bf5dbd26a814d35dbe24a5eb1b85"), `${label} new-unit independent package/terminal gate drifted`);
      invariant(pkg.signature_privacy_binding.sha256 === "fb5ab13d2793c87229238456dc52dddbe4fe35090e727ca6eec765073352b83b" && pkg.pck_sha256 === "eecb13831c625a3d09871a2f37f322316cdbc0df0c0f5e512a0bf08d54831691", `${label} accepted candidate app drifted`);
    } else {
    invariant(pkg.independent_package_review.sha256 === "665648ccc7fdc05241841e8201ec495809133f9c2acb522e9adef56bd6287773" && pkg.independent_terminal_slot_release.sha256 === "1a5d644aaa59fbdb46feffba65f43f263ca755b3cfb40f062608a3e2546cce27", `${label} shared independent package/byte gate drifted`);
    invariant(pkg.signature_privacy_binding.sha256 === "8103ac4a7962f23bca2f3c78eda13d139d1ab7f3696610d53189ce770893143e" && pkg.pck_sha256 === "9fef305dc9ac1f5d3866742143842ce5f691d1bc369dc41b775142fbf243ed86", `${label} shared candidate app drifted`);
    }
  }
}

function d21444AcceptanceRecord() {
  return {
    capture_time_recognition_metric: "9/213",
    evidence_manifest_sha256: D2_1444_EVIDENCE_MANIFEST_SHA256,
    evidence_tree_sha256: D2_1444_EVIDENCE_TREE_SHA256,
    mechanical_review_receipt_sha256: D2_1444_MECHANICAL_REVIEW_RECEIPT_SHA256,
    motion_telemetry_manifest_sha256: D2_1444_MOTION_TELEMETRY_MANIFEST_SHA256,
    numerator_effect: 1,
    package_verification_receipt_sha256: D2_1444_PACKAGE_VERIFICATION_RECEIPT_SHA256,
    review_id: D2_1444_REVIEW_ID,
    review_kind: "independent_reference_recognition",
    review_receipt_sha256: D2_1444_VISUAL_REVIEW_RECEIPT_SHA256,
    status: "accept",
    visual_motion_manifest_sha256: D2_1444_VISUAL_MOTION_MANIFEST_SHA256,
  };
}

function validateAcceptanceReceipt(unit, record) {
  const expectedKeys = ["evidence_manifest_sha256", "review_id", "review_kind", "review_receipt_sha256", "status"];
  for (const optionalKey of [
    "capture_time_recognition_metric",
    "evidence_tree_sha256",
    "mechanical_review_receipt_sha256",
    "motion_telemetry_manifest_sha256",
    "numerator_effect",
    "package_verification_receipt_sha256",
    "visual_motion_manifest_sha256",
  ]) {
    if (Object.hasOwn(record, optionalKey)) expectedKeys.push(optionalKey);
  }
  assertExactKeys(record, expectedKeys, `${unit.unit_id} acceptance record`);
  invariant(/^[0-9a-f]{64}$/u.test(record.evidence_manifest_sha256), `${unit.unit_id}/${record.review_id} evidence hash is invalid`);
  invariant(/^[0-9a-f]{64}$/u.test(record.review_receipt_sha256), `${unit.unit_id}/${record.review_id} review receipt hash is invalid`);
  invariant(["as_built_fidelity", "independent_game_art", "independent_reference_recognition", "mechanical_receiver"].includes(record.review_kind), `${unit.unit_id}/${record.review_id} review kind is invalid`);
  invariant(["accept", "reject"].includes(record.status), `${unit.unit_id}/${record.review_id} review status is invalid`);
  const receipt = REVIEW_RECEIPTS[record.review_id];
  invariant(receipt != null, `${unit.unit_id}/${record.review_id} is not an allowlisted independent review receipt`);
  invariant(receipt.unit_id === unit.unit_id, `${unit.unit_id}/${record.review_id} review receipt belongs to another physical unit`);
  invariant(record.review_receipt_sha256 === receipt.review_receipt_sha256, `${unit.unit_id}/${record.review_id} review receipt pin drifted`);
  invariant(record.evidence_manifest_sha256 === receipt.evidence_manifest_sha256, `${unit.unit_id}/${record.review_id} evidence manifest pin drifted`);
  if ([D2_1441_REVIEW_ID, D2_1439_REVIEW_ID, D2_1444_REVIEW_ID, ...D5_BATCH_ACCEPTED.map((d) => d.acceptance.review_id)].includes(record.review_id)) {
    invariant(equalStable(record, D5_BATCH_ACCEPTED.find((d) => d.acceptance.review_id === record.review_id)?.acceptance ?? (record.review_id === D2_1444_REVIEW_ID ? d21444AcceptanceRecord() : record.review_id === D2_1439_REVIEW_ID ? d21439AcceptanceRecord() : d21441AcceptanceRecord())), `${unit.unit_id}/${record.review_id} D2 1441 seven-artifact acceptance closure drifted`);
    for (const field of [
      "evidence_tree_sha256",
      "mechanical_review_receipt_sha256",
      "motion_telemetry_manifest_sha256",
      "package_verification_receipt_sha256",
      "visual_motion_manifest_sha256",
    ]) invariant(record[field] === receipt[field], `${unit.unit_id}/${record.review_id} ${field} pin drifted`);
  } else if (receipt.evidence_tree_sha256 != null) {
    invariant(record.evidence_tree_sha256 === receipt.evidence_tree_sha256, `${unit.unit_id}/${record.review_id} evidence tree pin drifted`);
    invariant(record.capture_time_recognition_metric === receipt.capture_time_recognition_metric, `${unit.unit_id}/${record.review_id} capture-time metric drifted`);
    invariant(record.numerator_effect === receipt.numerator_effect, `${unit.unit_id}/${record.review_id} numerator effect drifted`);
  } else {
    invariant(!expectedKeys.some((key) => ["capture_time_recognition_metric", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "motion_telemetry_manifest_sha256", "numerator_effect", "package_verification_receipt_sha256", "visual_motion_manifest_sha256"].includes(key)), `${unit.unit_id}/${record.review_id} adds unsupported acceptance authority fields`);
  }
  invariant(sha256File(absolute(receipt.review_path)) === receipt.review_receipt_sha256, `${unit.unit_id}/${record.review_id} independent review bytes drifted`);
  invariant(sha256File(absolute(receipt.evidence_manifest_path)) === receipt.evidence_manifest_sha256, `${unit.unit_id}/${record.review_id} evidence manifest bytes drifted`);
  if (receipt.evidence_tree_sha256 != null) {
    const reviewText = readFileSync(absolute(receipt.review_path), "utf8");
    invariant(reviewText.includes(receipt.evidence_tree_sha256), `${unit.unit_id}/${record.review_id} independent review does not bind the evidence tree`);
  }
}

function validateAuthoredRecognitionState(unit, receiverByKey, captureContract) {
  assertUnique(unit.human_dependency_ids, `${unit.unit_id} human dependencies`);
  invariant(unit.human_dependency_ids.every((id) => /^HUMAN-[0-9]+$/u.test(id)), `${unit.unit_id} has an invalid HUMAN dependency ID`);
  const referenceIds = [];
  for (const reference of unit.reference_records) {
    assertExactKeys(reference, ["observation_id", "observed_regions", "pixels_packaged", "source_locator", "supports"], `${unit.unit_id} reference record`);
    invariant(reference.pixels_packaged === false, `${unit.unit_id} reference pixels may not enter runtime/package data`);
    invariant(typeof reference.observation_id === "string" && reference.observation_id.length > 0, `${unit.unit_id} reference observation_id is invalid`);
    invariant(typeof reference.source_locator === "string" && reference.source_locator.length > 0, `${unit.unit_id} reference source locator is invalid`);
    invariant(Array.isArray(reference.observed_regions) && reference.observed_regions.length > 0, `${unit.unit_id} reference observed regions are empty`);
    invariant(Array.isArray(reference.supports) && reference.supports.length > 0, `${unit.unit_id} reference support claims are empty`);
    invariant(reference.observed_regions.every((region) => typeof region === "string" && region.length > 0), `${unit.unit_id}/${reference.observation_id} has an invalid observed region`);
    invariant(reference.supports.every((support) => typeof support === "string" && support.length > 0), `${unit.unit_id}/${reference.observation_id} has an invalid support claim`);
    assertUnique(reference.observed_regions, `${unit.unit_id}/${reference.observation_id} observed regions`);
    assertUnique(reference.supports, `${unit.unit_id}/${reference.observation_id} support claims`);
    referenceIds.push(reference.observation_id);
  }
  assertUnique(referenceIds, `${unit.unit_id} reference observation IDs`);
  const cueIds = [];
  for (const cue of unit.recognition_cues) {
    assertExactKeys(cue, ["complete_motif", "cue_id", "cue_kind", "evidence_class", "receiver_key", "reference_ids", "run_indices"], `${unit.unit_id} recognition cue`);
    invariant(typeof cue.cue_id === "string" && cue.cue_id.length > 0, `${unit.unit_id} cue_id is invalid`);
    invariant(["homogeneous_material_tile", "architectural_pattern_tile", "module_atlas", "unique_elevation"].includes(cue.cue_kind), `${unit.unit_id}/${cue.cue_id} cue kind is invalid`);
    invariant(["reference_observation", "production_inference", "verified_fact"].includes(cue.evidence_class), `${unit.unit_id}/${cue.cue_id} evidence class is invalid`);
    invariant(cue.complete_motif === true || cue.cue_kind === "homogeneous_material_tile", `${unit.unit_id}/${cue.cue_id} must preserve a complete motif`);
    invariant(unit.receiver_keys.includes(cue.receiver_key), `${unit.unit_id} cue escapes its receiver ownership`);
    invariant(Array.isArray(cue.run_indices), `${unit.unit_id} cue run_indices must be an array`);
    invariant(Array.isArray(cue.reference_ids), `${unit.unit_id}/${cue.cue_id} reference_ids must be an array`);
    assertUnique(cue.run_indices, `${unit.unit_id}/${cue.cue_id} cue runs`);
    assertUnique(cue.reference_ids, `${unit.unit_id}/${cue.cue_id} cue references`);
    invariant(cue.reference_ids.every((id) => referenceIds.includes(id)), `${unit.unit_id}/${cue.cue_id} cites an unknown reference observation`);
    const runCount = receiverByKey.get(cue.receiver_key).run_count;
    invariant(cue.run_indices.every((run) => Number.isInteger(run) && run >= 0 && run < runCount), `${unit.unit_id} cue contains an invalid run`);
    cueIds.push(cue.cue_id);
  }
  assertUnique(cueIds, `${unit.unit_id} recognition cue IDs`);
  if (captureContract != null) {
    invariant(captureContract.required_cue_ids.every((cueId) => cueIds.includes(cueId)), `${unit.unit_id} capture contract requires an unknown recognition cue`);
  }
  for (const scope of unit.protected_scopes) {
    assertExactKeys(scope, ["reason", "receiver_key", "run_indices"], `${unit.unit_id} protected scope`);
    invariant(unit.receiver_keys.includes(scope.receiver_key), `${unit.unit_id} protected scope escapes its receiver ownership`);
    invariant(Array.isArray(scope.run_indices), `${unit.unit_id} protected run_indices must be an array`);
    assertUnique(scope.run_indices, `${unit.unit_id} protected runs`);
    const runCount = receiverByKey.get(scope.receiver_key).run_count;
    invariant(scope.run_indices.every((run) => Number.isInteger(run) && run >= 0 && run < runCount), `${unit.unit_id} protected scope contains an invalid run`);
    invariant(!unit.recognition_cues.some((cue) => cue.receiver_key === scope.receiver_key && cue.run_indices.some((run) => scope.run_indices.includes(run))), `${unit.unit_id} recognition cue overlaps a protected run`);
  }
  const reviewIds = [];
  for (const record of unit.acceptance_records) {
    validateAcceptanceReceipt(unit, record);
    reviewIds.push(record.review_id);
  }
  assertUnique(reviewIds, `${unit.unit_id} review IDs`);
  if (unit.reference_state === "reference_ready") {
    invariant(unit.reference_records.length > 0, `${unit.unit_id} is reference-ready without a reference record`);
  }
  if (unit.reference_state === "reference_blocked") {
    invariant(unit.claim_status.reference_recognizable === "blocked" && unit.human_dependency_ids.length > 0, `${unit.unit_id} reference blocker lacks a narrow HUMAN dependency`);
  }
  if (unit.claim_status.reference_recognizable === "blocked") {
    invariant(unit.reference_state === "reference_blocked", `${unit.unit_id} has a blocked claim without a blocked reference state`);
  }
  if (unit.claim_status.game_distinctive === "accepted") {
    invariant(unit.recognition_cues.length > 0, `${unit.unit_id} cannot accept game distinctiveness without cues`);
    invariant(unit.acceptance_records.some((record) => record.review_kind === "independent_game_art" && record.status === "accept"), `${unit.unit_id} lacks independent game-art acceptance`);
    invariant(captureContract?.status === "configured", `${unit.unit_id} lacks a configured ordinary-gameplay capture contract`);
  }
  if (unit.claim_status.reference_recognizable === "accepted") {
    invariant(unit.reference_state === "reference_ready", `${unit.unit_id} cannot accept reference recognizability before reference readiness`);
    invariant(unit.reference_records.length > 0 && unit.recognition_cues.length > 0, `${unit.unit_id} cannot accept reference recognizability without references and cues`);
    invariant(unit.recognition_cues.every((cue) => cue.reference_ids.length > 0), `${unit.unit_id} reference recognition contains an uncited cue`);
    invariant(unit.acceptance_records.some((record) => record.review_kind === "independent_reference_recognition" && record.status === "accept"), `${unit.unit_id} lacks independent reference-recognition acceptance`);
    invariant(captureContract?.status === "configured", `${unit.unit_id} lacks a configured ordinary-gameplay capture contract`);
    invariant(equalStable([...captureContract.required_cue_ids].sort(), [...cueIds].sort()), `${unit.unit_id} capture contract does not require every recognition cue`);
  }
  if (unit.claim_status.as_built_fidelity !== "unclaimed") {
    invariant(unit.acceptance_records.some((record) => record.review_kind === "as_built_fidelity" && record.status === "accept"), `${unit.unit_id} lacks as-built acceptance evidence`);
  }
}

function runtimeReceiverBinding(receiverKey, receiver, expectedSourceKey, adapterBinding) {
  const record = receiver.record;
  invariant(record.source_keys[0] === expectedSourceKey, `${receiverKey} source ownership drifted from inventory`);
  return {
    chunk_id: receiver.chunk_id,
    chunk_sha256: receiver.chunk_sha256,
    collision_kind: record.collision_kind,
    exterior_foundation_runs: Number(record.exterior_foundation_segments ?? 0),
    feature_kind: record.feature_kind,
    geometry_sha256: sha256Stable({
      flat_base_elevation_m: record.flat_base_elevation_m,
      indices: record.indices,
      normals: record.normals,
      top_elevation_m: record.top_elevation_m,
      uvs: record.uvs,
      vertices: record.vertices,
    }),
    index_count: record.indices.length,
    opaque: record.opaque,
    receiver_key: receiverKey,
    record_sha256: sha256Stable(record),
    run_count: receiver.run_count,
    runtime_adapter_id: adapterBinding?.adapter_id ?? null,
    runtime_content_mode: adapterBinding?.content_mode ?? "generated_placeholder",
    shared_wall_runs: Number(record.shared_wall_segments ?? 0),
    source_key: record.source_keys[0],
    spray_receiver_expected: true,
    triangle_count: record.indices.length / 3,
    vertex_count: record.vertices.length / 3,
  };
}

function inventoryAttachmentByReceiver(inventory) {
  return new Map(
    inventory.runtime_material_contract.accepted_target_specific_runtime_attachments
      .map((attachment) => [attachment.receiver_key, attachment]),
  );
}

function acceptedRunScopes(attachment, runCount) {
  let candidates = [];
  if (Array.isArray(attachment.accepted_field_scopes) && attachment.accepted_field_scopes.length > 0) {
    candidates = attachment.accepted_field_scopes.map((scope, index) => ({
      run_indices: scope.accepted_runs ?? scope.exact_ordered_runs ?? [],
      scope_id: scope.scope_id ?? scope.field_id ?? `legacy-field-${index + 1}`,
    }));
  } else if (attachment.live_field_scope != null) {
    candidates = [{
      run_indices: attachment.live_field_scope.exact_ordered_runs ?? [],
      scope_id: attachment.live_field_scope.scope_id ?? attachment.live_field_scope.field_id ?? "legacy-live-field",
    }];
  } else if (Array.isArray(attachment.accepted_runs) && attachment.accepted_runs.length > 0) {
    candidates = [{
      run_indices: attachment.accepted_runs,
      scope_id: attachment.field_id ?? "legacy-accepted-runs",
    }];
  }
  return candidates.map((scope) => {
    const runs = [...scope.run_indices].map(Number);
    assertUnique(runs, `${attachment.receiver_key}/${scope.scope_id} accepted runs`);
    invariant(runs.every((run) => Number.isInteger(run) && run >= 0 && run < runCount), `${attachment.receiver_key}/${scope.scope_id} accepted run escapes receiver`);
    return { run_indices: runs, scope_id: scope.scope_id };
  });
}

function collectRuntimeAssetPaths(value, parentKey = "", output = new Set()) {
  if (Array.isArray(value)) {
    for (const item of value) collectRuntimeAssetPaths(item, parentKey, output);
    return output;
  }
  if (
    typeof value === "string" &&
    parentKey === "runtime_asset_paths" &&
    RUNTIME_PATH_PREFIXES.some((prefix) => value.startsWith(prefix))
  ) {
    output.add(value);
    return output;
  }
  if (value == null || typeof value !== "object") return output;
  for (const [key, child] of Object.entries(value)) {
    if (
      typeof child === "string" &&
      (RUNTIME_PATH_KEYS.has(key) || key === "path") &&
      RUNTIME_PATH_PREFIXES.some((prefix) => child.startsWith(prefix))
    ) {
      output.add(child);
    } else {
      collectRuntimeAssetPaths(child, key, output);
    }
  }
  return output;
}

const TEXT_RUNTIME_ASSET_EXTENSIONS = new Set([
  ".gd",
  ".gdshader",
  ".json",
  ".tres",
  ".tscn",
]);

function forbiddenAssetKinds(text) {
  const kinds = [];
  if (text.includes("discovery/")) kinds.push("discovery_path");
  if (text.includes("evidence/")) kinds.push("evidence_path");
  if (/https?:\/\//u.test(text)) kinds.push("reference_url");
  if (/(?:\/Users\/|\/Volumes\/)/u.test(text)) kinds.push("absolute_workstation_path");
  return kinds;
}

function runtimeDependencies(text) {
  const paths = [];
  for (const match of text.matchAll(/res:\/\/([^"'\s\]\[()<>]+)/gu)) {
    const path = match[1].replace(/[;,]+$/u, "");
    if (path.length > 0 && !path.endsWith("/")) paths.push(path);
  }
  return [...new Set(paths)].sort();
}

function acceptedAuthorityRuntimeDependencies(path, text) {
  const currentDependencies = runtimeDependencies(text);
  if (path !== WORLD_CHUNK_BUILDER_PATH) return currentDependencies;
  assertUnique(D2_1441_REVIEWED_WORLD_BUILDER_DEPENDENCY_PATHS, "Reviewed D2 1441 world-builder dependencies");
  for (const dependency of D2_1441_REVIEWED_WORLD_BUILDER_DEPENDENCY_PATHS) {
    invariant(currentDependencies.includes(dependency), `Current world builder lost accepted D2 1441 package dependency ${dependency}`);
  }
  return [...D2_1441_REVIEWED_WORLD_BUILDER_DEPENDENCY_PATHS].sort();
}

function inspectRuntimeAssetClosure(relativePath) {
  const nodes = new Map();
  function visit(path) {
    if (nodes.has(path)) return;
    const candidate = absolute(path);
    invariant(existsSync(candidate) && statSync(candidate).isFile(), `Runtime asset dependency is missing: ${path}`);
    const extension = extname(path).toLowerCase();
    const text = TEXT_RUNTIME_ASSET_EXTENSIONS.has(extension)
      ? readFileSync(candidate, "utf8")
      : "";
    const dependencies = acceptedAuthorityRuntimeDependencies(path, text);
    const violations = forbiddenAssetKinds(text);
    nodes.set(path, {
      asset_path: path,
      dependencies,
      sha256: sha256File(candidate),
      violations,
    });
    for (const dependency of dependencies) {
      if (dependency.startsWith("discovery/") || dependency.startsWith("evidence/")) continue;
      visit(dependency);
    }
  }
  visit(relativePath);
  const closureAssets = [...nodes.values()].sort((left, right) => left.asset_path.localeCompare(right.asset_path));
  return {
    closure_assets: closureAssets,
    closure_clean: closureAssets.every((asset) => asset.violations.length === 0),
    direct_asset_path: relativePath,
    direct_asset_sha256: sha256File(absolute(relativePath)),
    violation_count: closureAssets.reduce((sum, asset) => sum + asset.violations.length, 0),
  };
}

function runtimeAssetProjection(adapterId, audit) {
  return {
    package_contract: "sanitized_adapter_metadata_summary_only",
    projection_id: `runtime-projection:${sha256Stable({
      adapter_id: adapterId,
      direct_asset_path: audit.direct_asset_path,
      direct_asset_sha256: audit.direct_asset_sha256,
    })}`,
    source_asset_sha256: audit.direct_asset_sha256,
    source_asset_type: extname(audit.direct_asset_path).slice(1) || "file",
  };
}

function runtimeAssets(attachment, adapterId, packageAudit) {
  const paths = [...collectRuntimeAssetPaths(attachment)].sort();
  const safe = [];
  const projections = [];
  for (const path of paths) {
    const candidate = absolute(path);
    invariant(existsSync(candidate) && statSync(candidate).isFile(), `Accepted legacy runtime asset is missing: ${path}`);
    const audit = inspectRuntimeAssetClosure(path);
    packageAudit.push({ adapter_id: adapterId, ...audit });
    if (audit.closure_clean) {
      safe.push({ path: `res://${path}`, sha256: sha256File(candidate) });
    } else {
      projections.push(runtimeAssetProjection(adapterId, audit));
    }
  }
  return {
    package_integration_state: projections.length === 0
      ? "package_safe_asset_closure"
      : "sanitized_summary_requires_future_package_safe_adapter",
    runtime_asset_projections: projections,
    runtime_assets: safe,
  };
}

function importLegacyAdapter(seed, attachment, receiver, packageAudit) {
  invariant(attachment != null, `${seed.adapter_id} lacks its inventory attachment`);
  invariant(attachment.source_key === seed.source_key && attachment.receiver_key === seed.receiver_key, `${seed.adapter_id} attachment identity drifted`);
  const moduleScope = attachment.accepted_live_module_scope ?? {};
  const modulePlacementCount = Number(
    moduleScope.placement_count ?? attachment.accepted_module_placement_count ?? 0,
  );
  invariant(Number.isInteger(modulePlacementCount) && modulePlacementCount >= 0, `${seed.adapter_id} module count is invalid`);
  const packaged = runtimeAssets({ attachment }, seed.adapter_id, packageAudit);
  return {
    ...packaged,
    accepted_run_scopes: acceptedRunScopes(attachment, receiver.run_count),
    adapter_id: seed.adapter_id,
    attachment_kind: attachment.attachment_kind ?? (attachment.facade_scene_path ? "legacy_facade_scene" : "legacy_runtime_attachment"),
    inventory_attachment_sha256: sha256Stable(attachment),
    module_placement_count: modulePlacementCount,
    receiver_key: seed.receiver_key,
    recognition_claim_effect: "none",
    source_key: seed.source_key,
    state: "existing_independently_accepted_target_specific_runtime_content",
    whole_building_recognizability_imported: false,
  };
}

function sanitizedHeroConfig(config) {
  return {
    facade_schedule: config.facade_schedule,
    massing_chains: config.massing_chains,
    model_id: config.model_id,
    schema_version: config.schema_version,
    target: config.target,
    truth_boundary: config.truth_boundary,
    vertical_production_inference_m: config.vertical_production_inference_m,
  };
}

function sanitizedBuilding3Config(config) {
  return {
    authoritative_identity: config.authoritative_identity,
    reference_supported_family: config.reference_supported_family,
    reversible_production_inference: config.reversible_production_inference,
    schema_version: config.schema_version,
    target: config.target,
    truth_boundary: config.truth_boundary,
  };
}

function sanitizedIsleHouseConfig(config) {
  return {
    public_sides: config.public_sides,
    render_contract: config.render_contract,
    schema_version: config.schema_version,
    target: config.target,
    truth_boundary: config.truth_boundary,
  };
}

function sanitizedNavyChapelConfig(config) {
  return {
    mapped_runs: config.mapped_runs,
    material_scope: config.material_scope,
    model_id: config.model_id,
    protected_regions: config.protected_regions,
    schema_version: config.schema_version,
    target: {
      canonical_name: config.target.canonical_name,
      source_key: config.target.source_key,
      wall_object_key: config.target.wall_object_key,
      roof_object_key: config.target.roof_object_key,
      wall_run_count: config.target.wall_run_count,
      wall_triangles: config.target.wall_triangles,
      roof_triangles: config.target.roof_triangles,
    },
    truth_boundary: {
      all_unsurveyed_dimensions_and_cadence: config.truth_boundary.all_unsurveyed_dimensions_and_cadence,
      as_built_claim: config.truth_boundary.as_built_claim,
      horizontal_source_footprint_changed: config.truth_boundary.horizontal_source_footprint_changed,
      source_identity_changed: config.truth_boundary.source_identity_changed,
    },
  };
}

function sanitizedD1B201Config(config) {
  return {
    attachment_id: config.attachment_id,
    eligible_public_chain: config.eligible_public_chain,
    production_translation: config.production_translation,
    protected_scope: config.protected_scope,
    receiver_key: config.receiver_key,
    runtime_contract: config.runtime_contract,
    schema_version: config.schema_version,
    source_boundary: config.source_boundary,
    source_key: config.source_key,
    supplied_record_authority: config.supplied_record_authority,
  };
}

function sanitizedD1B225Config(config) {
  return {
    approved_geometry: config.approved_geometry,
    attachment_id: config.attachment_id,
    eligible_public_chain: config.eligible_public_chain,
    production_translation: config.production_translation,
    protected_scope: config.protected_scope,
    receiver_key: config.receiver_key,
    runtime_contract: config.runtime_contract,
    schema_version: config.schema_version,
    source_boundary: config.source_boundary,
    source_key: config.source_key,
    supplied_record_authority: config.supplied_record_authority,
  };
}

function sanitizedD21441Config(config) {
  return {
    live_pair_contract: config.live_pair_contract,
    model_id: config.model_id,
    package_boundary: config.package_boundary,
    reviewed_art: config.reviewed_art,
    schema_version: config.schema_version,
    target: config.target,
    topology_transition: config.topology_transition,
    truth_boundary: config.truth_boundary,
  };
}

function sanitizedD21439Config(config) {
  return {
    live_pair_contract: config.live_pair_contract,
    model_id: config.model_id,
    package_boundary: config.package_boundary,
    reviewed_art: config.reviewed_art,
    schema_version: config.schema_version,
    target: config.target,
    truth_boundary: config.truth_boundary,
  };
}

function sanitizedD21444Config(config) {
  return {
    live_pair_contract: config.live_pair_contract,
    model_id: config.model_id,
    package_boundary: config.package_boundary,
    reviewed_art: config.reviewed_art,
    schema_version: config.schema_version,
    target: config.target,
    truth_boundary: config.truth_boundary,
  };
}

function activeContentMode(adapter) {
  const d5 = D5_BATCH_ACCEPTED.find((d) => d.wall === adapter.receiver_key);
  if (d5) return d5.mode;
  if (adapter.receiver_key === BUILDING_3_WALL) return "active_building_3_hero";
  if (adapter.receiver_key === ISLE_HOUSE_LOW_WALL) return "active_isle_house_variant_c";
  if (adapter.receiver_key === NAVY_CHAPEL_WALL) return "active_navy_chapel_187_paired_replacement";
  if (adapter.receiver_key === D1_B201_WALL) return "active_d1_b201_host_partition_attachment";
  if (adapter.receiver_key === D1_B225_WALL) return "active_d1_b225_host_partition_attachment";
  if (adapter.receiver_key === D2_1441_WALL) return "active_d2_1441_paired_replacement";
  if (adapter.receiver_key === D2_1439_WALL) return "active_d2_1439_paired_replacement";
  if (adapter.receiver_key === D2_1444_WALL) return "active_d2_1444_paired_replacement";
  return "active_building_1_hero";
}

function importActiveRuntimeAdapter(seed, receiver, inputs, packageAudit) {
  invariant(receiver != null, `${seed.adapter_id} receiver is missing`);
  invariant(receiver.record.source_keys[0] === seed.source_key, `${seed.adapter_id} source ownership drifted`);
  const packaged = runtimeAssets(seed, seed.adapter_id, packageAudit);
  const isBuilding3 = seed.receiver_key === BUILDING_3_WALL;
  const isIsleHouse = seed.receiver_key === ISLE_HOUSE_LOW_WALL;
  const isNavyChapel = seed.receiver_key === NAVY_CHAPEL_WALL;
  const isD1B201 = seed.receiver_key === D1_B201_WALL;
  const isD1B225 = seed.receiver_key === D1_B225_WALL;
  const isD21441 = seed.receiver_key === D2_1441_WALL;
  const isD21439 = seed.receiver_key === D2_1439_WALL;
  const isD21444 = seed.receiver_key === D2_1444_WALL;
  const d5 = D5_BATCH_ACCEPTED.find((d) => d.wall === seed.receiver_key);
  const activeRuntimeContract = d5 ? {
    adapter_sha256: d5.hashes.adapter, behavior_contract: d5.behavior, config_sha256: d5.hashes.config, config_summary: d5.config, dispatch_sha256: D5_BATCH_BUILDER_SHA256, prototype_config_sha256: d5.hashes.factory_config, prototype_sha256: d5.hashes.factory, site_kit_sha256: d5.hashes.site_kit,
  } : isBuilding3
    ? {
      adapter_sha256: inputs.runtimeContracts.building3MassingSha256,
      behavior_contract: building3BehaviorContract(),
      config_sha256: inputs.runtimeContracts.building3ConfigSha256,
      config_summary: sanitizedBuilding3Config(inputs.runtimeContracts.building3Config),
      dispatch_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256,
    }
    : isIsleHouse
      ? {
        adapter_sha256: inputs.runtimeContracts.isleHouseLiveAdapterSha256,
        behavior_contract: isleHouseBehaviorContract(),
        config_sha256: inputs.runtimeContracts.isleHouseConfigSha256,
        config_summary: sanitizedIsleHouseConfig(inputs.runtimeContracts.isleHouseConfig),
        dispatch_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256,
        repair_factory_sha256: inputs.runtimeContracts.isleHouseRepairFactorySha256,
        reviewed_factory_sha256: inputs.runtimeContracts.isleHouseReviewedFactorySha256,
      }
    : isNavyChapel
      ? {
        adapter_sha256: inputs.runtimeContracts.navyChapelLiveAdapterSha256,
        behavior_contract: navyChapelBehaviorContract(),
        config_sha256: inputs.runtimeContracts.navyChapelConfigSha256,
        config_summary: sanitizedNavyChapelConfig(inputs.runtimeContracts.navyChapelConfig),
        dispatch_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256,
        prototype_sha256: inputs.runtimeContracts.navyChapelPrototypeSha256,
      }
    : isD21441
      ? {
        adapter_sha256: inputs.runtimeContracts.d21441LiveAdapterSha256,
        behavior_contract: d21441BehaviorContract(),
        config_sha256: inputs.runtimeContracts.d21441ConfigSha256,
        config_summary: sanitizedD21441Config(inputs.runtimeContracts.d21441Config),
        dispatch_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256,
        prototype_config_sha256: inputs.runtimeContracts.d21441PrototypeConfigSha256,
        prototype_sha256: inputs.runtimeContracts.d21441PrototypeSha256,
        site_kit_sha256: inputs.runtimeContracts.d21441SiteKitSha256,
      }
    : isD21439
      ? {
        adapter_sha256: inputs.runtimeContracts.d21439LiveAdapterSha256,
        behavior_contract: d21439BehaviorContract(),
        config_sha256: inputs.runtimeContracts.d21439ConfigSha256,
        config_summary: sanitizedD21439Config(inputs.runtimeContracts.d21439Config),
        dispatch_sha256: D2_1439_REVIEWED_WORLD_BUILDER_SHA256,
        prototype_config_sha256: inputs.runtimeContracts.d21439PrototypeConfigSha256,
        prototype_sha256: inputs.runtimeContracts.d21439PrototypeSha256,
        site_kit_sha256: inputs.runtimeContracts.d21439SiteKitSha256,
      }
    : isD21444
      ? {
        adapter_sha256: inputs.runtimeContracts.d21444LiveAdapterSha256,
        behavior_contract: d21444BehaviorContract(),
        config_sha256: inputs.runtimeContracts.d21444ConfigSha256,
        config_summary: sanitizedD21444Config(inputs.runtimeContracts.d21444Config),
        dispatch_sha256: D2_1444_REVIEWED_WORLD_BUILDER_SHA256,
        prototype_config_sha256: inputs.runtimeContracts.d21444PrototypeConfigSha256,
        prototype_sha256: inputs.runtimeContracts.d21444PrototypeSha256,
        site_kit_sha256: inputs.runtimeContracts.d21444SiteKitSha256,
      }
    : isD1B201
      ? {
        adapter_sha256: inputs.runtimeContracts.d1B201LiveAdapterSha256,
        behavior_contract: d1B201BehaviorContract(),
        config_sha256: inputs.runtimeContracts.d1B201ConfigSha256,
        config_summary: sanitizedD1B201Config(inputs.runtimeContracts.d1B201Config),
        dispatch_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256,
      }
    : isD1B225
      ? {
        adapter_sha256: inputs.runtimeContracts.d1B225LiveAdapterSha256,
        behavior_contract: d1B225BehaviorContract(),
        config_sha256: inputs.runtimeContracts.d1B225ConfigSha256,
        config_summary: sanitizedD1B225Config(inputs.runtimeContracts.d1B225Config),
        dispatch_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256,
      }
    : {
      adapter_sha256: inputs.runtimeContracts.heroAdapterSha256,
      behavior_contract: null,
      config_sha256: inputs.runtimeContracts.heroConfigSha256,
      config_summary: sanitizedHeroConfig(inputs.runtimeContracts.heroConfig),
      dispatch_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256,
      public_front_config_sha256: inputs.runtimeContracts.heroPublicFrontConfigSha256,
    };
  return {
    ...packaged,
    accepted_run_scopes: [],
    active_receiver_scope: {
      coverage: "whole_direct_wall_receiver",
      run_count: receiver.run_count,
    },
    active_runtime_contract: activeRuntimeContract,
    adapter_id: seed.adapter_id,
    attachment_kind: d5 ? (d5.attachment_kind ?? `active_d5_${d5.number}_paired_wall_roof_replacement`) : isBuilding3
      ? "active_building_3_wall_roof_hero_replacement"
      : isIsleHouse
        ? "active_isle_house_variant_c_low_part_replacement"
        : isNavyChapel
          ? "active_navy_chapel_187_paired_wall_roof_replacement"
        : isD21441
          ? "active_d2_1441_paired_wall_roof_replacement"
        : isD21439
          ? "active_d2_1439_paired_wall_roof_replacement"
        : isD21444
          ? "active_d2_1444_paired_wall_roof_replacement"
          : isD1B201
            ? "active_d1_b201_receiver_host_partition_attachment"
          : isD1B225
            ? "active_d1_b225_receiver_host_partition_attachment"
        : "active_building_1_hero_replacement",
    content_classification: seed.content_classification,
    receiver_key: seed.receiver_key,
    recognition_acceptance_authority: seed.recognition_acceptance_authority,
    recognition_acceptance_status: seed.recognition_acceptance_status,
    recognition_claim_effect: "none",
    review_status: seed.review_status,
    review_status_scope: seed.review_status_scope,
    runtime_content_mode: activeContentMode(seed),
    source_key: seed.source_key,
    state: "active_runtime_target_specific_content",
    whole_building_recognizability_imported: false,
  };
}

function expectedDirectSource(unit, receiverKey) {
  if (unit.unit_kind === "standalone_building") return unit.anchor_source_key;
  const match = unit.source_records.find((source) => receiverKey.includes(`:${source.source_key}:wall`));
  invariant(match != null, `${unit.unit_id} cannot resolve direct source for ${receiverKey}`);
  return match.source_key;
}

function claimTotals(units) {
  const totals = {
    as_built_fidelity: { claimed: 0, limited: 0, unclaimed: 0 },
    game_distinctive: { accepted: 0, not_evaluated: 0, rejected: 0 },
    receiver_complete: { failed: 0, verified: 0 },
    reference_recognizable: { accepted: 0, blocked: 0, not_evaluated: 0, rejected: 0 },
  };
  for (const unit of units) {
    for (const [claim, status] of Object.entries(unit.claim_status)) {
      invariant(Object.hasOwn(totals[claim], status), `${unit.unit_id} has unknown ${claim} status ${status}`);
      totals[claim][status] += 1;
    }
  }
  return totals;
}

function identityCounts(inventory, catalogUnits) {
  const sourceIdentities = inventory.objects.map((object) => ({
    ...identityFor(object),
    canonical_name_evidence: typeof object.identity.canonical_name === "string" && object.identity.canonical_name.length > 0,
  }));
  const unitIdentities = catalogUnits.map((unit) => ({
    ...unit.identity,
    canonical_name_evidence: unit.identity.name_evidence,
  }));
  const summarize = (identities) => ({
    address_evidence: identities.filter((identity) => identity.address_evidence).length,
    canonical_name_evidence: identities.filter((identity) => identity.canonical_name_evidence).length,
    name_evidence_including_inherited: identities.filter((identity) => identity.name_evidence).length,
    name_or_address_evidence: identities.filter((identity) => identity.name_evidence || identity.address_evidence).length,
    neither_name_nor_address: identities.filter((identity) => !identity.name_evidence && !identity.address_evidence).length,
    source_key_only_confidence: identities.filter((identity) => identity.identity_confidence === "source_key_only").length,
  });
  return {
    recognition_units: summarize(unitIdentities),
    source_records: summarize(sourceIdentities),
  };
}

function runtimeIdentityAssertion(record) {
  return {
    asserted_value: record.evidenced_value,
    assertion_id: record.assertion_id,
    currentness_claimed: record.currentness_claimed,
    evidence_class: record.evidence_class,
    frozen_field: record.frozen_field,
    frozen_source_value: record.frozen_value,
    frozen_value_preserved: true,
    supersedes_frozen_value: record.evidenced_value !== record.frozen_value,
  };
}

function runtimeCaptureContract(capture) {
  if (capture == null) return { status: "unconfigured" };
  return {
    alternate_pose: capture.alternate_pose,
    ordinary_third_person_required: capture.ordinary_third_person_required,
    primary_pose: capture.primary_pose,
    required_cue_ids: capture.required_cue_ids,
    status: capture.status,
  };
}

function runtimeAcceptanceRecord(record) {
  const result = {
    evidence_manifest_sha256: record.evidence_manifest_sha256,
    review_id: record.review_id,
    review_kind: record.review_kind,
    review_receipt_sha256: record.review_receipt_sha256,
    status: record.status,
  };
  for (const optionalKey of [
    "capture_time_recognition_metric",
    "evidence_tree_sha256",
    "mechanical_review_receipt_sha256",
    "motion_telemetry_manifest_sha256",
    "numerator_effect",
    "package_verification_receipt_sha256",
    "visual_motion_manifest_sha256",
  ]) {
    if (Object.hasOwn(record, optionalKey)) result[optionalKey] = record[optionalKey];
  }
  return result;
}

function unitRuntimeContentMode(directReceivers) {
  for (const d of D5_BATCH_ACCEPTED) {
    if (directReceivers.every((r) => r.runtime_content_mode === d.mode)) return `all_receivers_${d.mode}`;
  }
  const modes = [...new Set(directReceivers.map((receiver) => receiver.runtime_content_mode))];
  if (modes.length === 1) {
    if (modes[0] === "generated_placeholder") return "all_receivers_generated_placeholder";
    if (modes[0] === "legacy_adapter") return "all_receivers_legacy_adapter";
    if (modes[0] === "active_building_1_hero") return "all_receivers_active_building_1_hero";
    if (modes[0] === "active_building_3_hero") return "all_receivers_active_building_3_hero";
    if (modes[0] === "active_isle_house_variant_c") return "all_receivers_active_isle_house_variant_c";
    if (modes[0] === "active_navy_chapel_187_paired_replacement") return "all_receivers_active_navy_chapel_187_paired_replacement";
    if (modes[0] === "active_d1_b201_host_partition_attachment") return "all_receivers_active_d1_b201_host_partition_attachment";
    if (modes[0] === "active_d1_b225_host_partition_attachment") return "all_receivers_active_d1_b225_host_partition_attachment";
    if (modes[0] === "active_d2_1441_paired_replacement") return "all_receivers_active_d2_1441_paired_replacement";
    if (modes[0] === "active_d2_1439_paired_replacement") return "all_receivers_active_d2_1439_paired_replacement";
    if (modes[0] === "active_d2_1444_paired_replacement") return "all_receivers_active_d2_1444_paired_replacement";
  }
  if (equalStable([...modes].sort(), ["generated_placeholder", "legacy_adapter"])) {
    return "mixed_legacy_adapter_and_generated_placeholder";
  }
  if (equalStable([...modes].sort(), ["active_isle_house_variant_c", "legacy_adapter"])) {
    return "mixed_legacy_high_and_active_variant_c_low";
  }
  return "mixed_runtime_content";
}

function executableAssetKind(path) {
  if (path.endsWith(".gd") && path.startsWith("res://game/scripts/world/")) return "gdscript";
  if (path.endsWith(".tscn") && path.startsWith("res://game/scenes/world/")) return "packed_scene";
  return null;
}

function projectionDescriptorId(projection) {
  return `disabled-projection-input:${sha256Stable({
    source_asset_sha256: projection.source_asset_sha256,
    source_asset_type: projection.source_asset_type,
  })}`;
}

function buildAdapterContracts(catalog, importedLegacyAdapters, importedActiveAdapters) {
  const adapters = [...importedLegacyAdapters, ...importedActiveAdapters];
  const projectionBySource = new Map();
  const plans = adapters.map((adapter) => {
    const projectionDescriptorIds = [];
    for (const projection of adapter.runtime_asset_projections) {
      const descriptorId = projectionDescriptorId(projection);
      const key = `${projection.source_asset_type}:${projection.source_asset_sha256}`;
      let descriptor = projectionBySource.get(key);
      if (descriptor == null) {
        descriptor = {
          consumer_adapter_ids: new Set(),
          descriptor_id: descriptorId,
          disabled_reason_code: "source_bearing_dependency_closure_requires_independent_package_safe_normalization",
          execution_policy: "never_resolve_or_execute",
          execution_state: "hard_disabled",
          occurrence_projection_ids: new Set(),
          source_asset_sha256: projection.source_asset_sha256,
          source_asset_type: projection.source_asset_type,
        };
        projectionBySource.set(key, descriptor);
      }
      invariant(descriptor.descriptor_id === descriptorId, `${adapter.adapter_id} projection descriptor identity drifted`);
      descriptor.consumer_adapter_ids.add(adapter.adapter_id);
      descriptor.occurrence_projection_ids.add(projection.projection_id);
      projectionDescriptorIds.push(descriptorId);
    }
    const hardDisabled = projectionDescriptorIds.length > 0;
    const runtimeAssets = adapter.runtime_assets.map((asset) => ({ ...asset }));
    const executableAssets = hardDisabled
      ? []
      : runtimeAssets.flatMap((asset) => {
        const resourceKind = executableAssetKind(asset.path);
        return resourceKind == null ? [] : [{ ...asset, resource_kind: resourceKind }];
      });
    return {
      adapter_id: adapter.adapter_id,
      behavior_contract: adapter.active_runtime_contract?.behavior_contract ?? null,
      content_mode: adapter.runtime_content_mode ?? "legacy_adapter",
      disabled_reason_code: hardDisabled
        ? "one_or_more_source_bearing_projection_inputs_have_no_parity_proven_package_safe_executable"
        : null,
      executable_assets: executableAssets,
      integration_state: hardDisabled ? "hard_disabled_source_projection" : "package_safe_ready_for_integration",
      projection_descriptor_ids: [...new Set(projectionDescriptorIds)].sort(),
      receiver_key: adapter.receiver_key,
      resolution_policy: hardDisabled ? "deny_all_executable_resolution" : "resolve_only_without_instantiation",
      runtime_assets: runtimeAssets,
      source_key: adapter.source_key,
    };
  }).sort((left, right) => left.receiver_key.localeCompare(right.receiver_key));
  const projectionDescriptors = [...projectionBySource.values()].map((descriptor) => ({
    ...descriptor,
    consumer_adapter_ids: [...descriptor.consumer_adapter_ids].sort(),
    occurrence_projection_ids: [...descriptor.occurrence_projection_ids].sort(),
  })).sort((left, right) => left.descriptor_id.localeCompare(right.descriptor_id));
  const disabledPlans = plans.filter((plan) => plan.integration_state === "hard_disabled_source_projection");
  const projectionOccurrences = projectionDescriptors.reduce(
    (sum, descriptor) => sum + descriptor.occurrence_projection_ids.length,
    0,
  );
  const contracts = {
    build_contract: {
      authoring_catalog_sha256: sha256File(absolute(PATHS.catalog)),
      compiler_version: COMPILER_VERSION,
      runtime_registry_schema_version: RUNTIME_SCHEMA,
      unknown_version_policy: UNKNOWN_VERSION_POLICY,
    },
    contract_id: "treasure-island-facade-runtime-adapters",
    counts: {
      disabled_adapter_receivers: disabledPlans.length,
      disabled_projection_occurrences: projectionOccurrences,
      disabled_unique_projection_inputs: projectionDescriptors.length,
      package_safe_adapter_receivers: plans.length - disabledPlans.length,
      receiver_adapter_plans: plans.length,
    },
    loader_contract: {
      allowed_executable_kinds: ["gdscript", "packed_scene"],
      allowed_executable_roots: ["res://game/scenes/world/", "res://game/scripts/world/"],
      api_version: LOADER_API_VERSION,
      instantiation_authorized: false,
      loader_path: `res://${FACADE_RUNTIME_LOADER_PATH}`,
      loader_sha256: sha256File(absolute(FACADE_RUNTIME_LOADER_PATH)),
      projection_execution_policy: "forbidden",
      unknown_version_policy: UNKNOWN_VERSION_POLICY,
    },
    plans,
    projection_descriptors: projectionDescriptors,
    schema_version: ADAPTER_CONTRACT_SCHEMA,
  };
  validateAdapterContracts(contracts);
  return contracts;
}

function validateAdapterContracts(contracts, registry = null) {
  assertExactKeys(contracts, [
    "build_contract",
    "contract_id",
    "counts",
    "loader_contract",
    "plans",
    "projection_descriptors",
    "schema_version",
  ], "Facade runtime adapter contracts");
  invariant(contracts.schema_version === ADAPTER_CONTRACT_SCHEMA, "Facade runtime adapter contract schema is unknown or forward-incompatible");
  invariant(contracts.contract_id === "treasure-island-facade-runtime-adapters", "Facade runtime adapter contract identity drifted");
  invariant(equalStable(contracts.counts, EXPECTED_ADAPTER_CONTRACTS), "Facade runtime adapter contract counts drifted");
  invariant(equalStable(contracts.build_contract, {
    authoring_catalog_sha256: contracts.build_contract.authoring_catalog_sha256,
    compiler_version: COMPILER_VERSION,
    runtime_registry_schema_version: RUNTIME_SCHEMA,
    unknown_version_policy: UNKNOWN_VERSION_POLICY,
  }), "Facade runtime adapter build compatibility is unknown or forward-incompatible");
  invariant(/^[0-9a-f]{64}$/u.test(contracts.build_contract.authoring_catalog_sha256), "Facade runtime adapter catalog hash is malformed");
  invariant(equalStable(contracts.loader_contract, {
    allowed_executable_kinds: ["gdscript", "packed_scene"],
    allowed_executable_roots: ["res://game/scenes/world/", "res://game/scripts/world/"],
    api_version: LOADER_API_VERSION,
    instantiation_authorized: false,
    loader_path: `res://${FACADE_RUNTIME_LOADER_PATH}`,
    loader_sha256: sha256File(absolute(FACADE_RUNTIME_LOADER_PATH)),
    projection_execution_policy: "forbidden",
    unknown_version_policy: UNKNOWN_VERSION_POLICY,
  }), "Facade runtime loader compatibility contract drifted or requests an unsupported future version");
  invariant(Array.isArray(contracts.plans) && contracts.plans.length === EXPECTED.runtime_adapter_receivers, `Facade runtime adapter plans do not cover ${EXPECTED.runtime_adapter_receivers} receivers`);
  invariant(Array.isArray(contracts.projection_descriptors) && contracts.projection_descriptors.length === EXPECTED_ADAPTER_CONTRACTS.disabled_unique_projection_inputs, "Facade runtime projection descriptors do not cover the exact disabled unique-input set");
  assertUnique(contracts.plans.map((plan) => plan.adapter_id), "Facade runtime adapter plan IDs");
  assertUnique(contracts.plans.map((plan) => plan.receiver_key), "Facade runtime adapter plan receivers");
  assertUnique(contracts.projection_descriptors.map((descriptor) => descriptor.descriptor_id), "Facade runtime projection descriptor IDs");
  const descriptorById = new Map(contracts.projection_descriptors.map((descriptor) => [descriptor.descriptor_id, descriptor]));
  const adapterById = registry == null
    ? null
    : new Map([...registry.legacy_adapters, ...registry.active_runtime_adapters].map((adapter) => [adapter.adapter_id, adapter]));
  if (registry != null) {
    invariant(contracts.build_contract.authoring_catalog_sha256 === registry.build_contract.authoring_catalog_sha256, "Facade runtime adapter contract catalog identity drifted from the registry");
    invariant(sha256Bytes(stableJson(contracts)) === registry.adapter_contract.sha256, "Facade runtime adapter contract hash drifted from the registry");
  }
  for (const plan of contracts.plans) {
    assertExactKeys(plan, [
      "adapter_id",
      "behavior_contract",
      "content_mode",
      "disabled_reason_code",
      "executable_assets",
      "integration_state",
      "projection_descriptor_ids",
      "receiver_key",
      "resolution_policy",
      "runtime_assets",
      "source_key",
    ], `Facade runtime adapter plan ${plan.adapter_id}`);
    invariant(["legacy_adapter", "active_building_1_hero", "active_building_3_hero", "active_isle_house_variant_c", "active_navy_chapel_187_paired_replacement", "active_d1_b201_host_partition_attachment", "active_d1_b225_host_partition_attachment", "active_d2_1441_paired_replacement", "active_d2_1439_paired_replacement", "active_d2_1444_paired_replacement", ...D5_BATCH_ACCEPTED.map((d) => d.mode)].includes(plan.content_mode), `${plan.adapter_id} has an unknown receiver content mode`);
    if (plan.content_mode === "active_building_3_hero") {
      invariant(equalStable(plan.behavior_contract, building3BehaviorContract()), `${plan.adapter_id} Building 3 behavior parity contract drifted`);
    } else if (plan.content_mode === "active_isle_house_variant_c") {
      invariant(equalStable(plan.behavior_contract, isleHouseBehaviorContract()), `${plan.adapter_id} Isle House pre-B201 integration live parity contract drifted`);
    } else if (plan.content_mode === "active_navy_chapel_187_paired_replacement") {
      invariant(equalStable(plan.behavior_contract, navyChapelBehaviorContract()), `${plan.adapter_id} Navy Chapel pre-B201 integration live parity contract drifted`);
    } else if (plan.content_mode === "active_d1_b201_host_partition_attachment") {
      invariant(equalStable(plan.behavior_contract, d1B201BehaviorContract()), `${plan.adapter_id} D1 B201 pre-B225 acceptance/parity contract drifted`);
    } else if (plan.content_mode === "active_d1_b225_host_partition_attachment") {
      invariant(equalStable(plan.behavior_contract, d1B225BehaviorContract()), `${plan.adapter_id} D1 B225 pre-D2 acceptance/parity contract drifted`);
    } else if (plan.content_mode === "active_d2_1441_paired_replacement") {
      invariant(equalStable(plan.behavior_contract, d21441BehaviorContract()), `${plan.adapter_id} D2 1441 exact-current acceptance/parity contract drifted`);
    } else if (plan.content_mode === "active_d2_1439_paired_replacement") {
      invariant(equalStable(plan.behavior_contract, d21439BehaviorContract()), `${plan.adapter_id} D2 1439 exact-current acceptance/parity contract drifted`);
    } else if (plan.content_mode === "active_d2_1444_paired_replacement") {
      invariant(equalStable(plan.behavior_contract, d21444BehaviorContract()), `${plan.adapter_id} D2 1444 exact-current acceptance/parity contract drifted`);
    } else if (D5_BATCH_ACCEPTED.some((d) => d.mode === plan.content_mode)) {
      const d = D5_BATCH_ACCEPTED.find((item) => item.mode === plan.content_mode);
      invariant(plan.receiver_key === d.wall && equalStable(plan.behavior_contract, d.behavior), `D5 ${d.number} plan behavior/ownership drifted`);
      invariant(plan.executable_assets.length === 3 && plan.projection_descriptor_ids.length === 0, `D5 ${d.number} executable/projection boundary drifted`);
    } else {
      invariant(plan.behavior_contract == null, `${plan.adapter_id} unexpectedly exports a target-specific behavior parity contract`);
    }
    invariant(Array.isArray(plan.runtime_assets) && Array.isArray(plan.executable_assets) && Array.isArray(plan.projection_descriptor_ids), `${plan.adapter_id} adapter plan arrays are malformed`);
    assertUnique(plan.runtime_assets.map((asset) => asset.path), `${plan.adapter_id} contract runtime assets`);
    assertUnique(plan.executable_assets.map((asset) => asset.path), `${plan.adapter_id} contract executable assets`);
    assertUnique(plan.projection_descriptor_ids, `${plan.adapter_id} projection descriptors`);
    invariant(plan.projection_descriptor_ids.every((id) => descriptorById.has(id)), `${plan.adapter_id} references an unknown projection descriptor`);
    invariant(plan.projection_descriptor_ids.every((id) => descriptorById.get(id).consumer_adapter_ids.includes(plan.adapter_id)), `${plan.adapter_id} is absent from a referenced projection descriptor's consumers`);
    const hardDisabled = plan.projection_descriptor_ids.length > 0;
    invariant(plan.integration_state === (hardDisabled ? "hard_disabled_source_projection" : "package_safe_ready_for_integration"), `${plan.adapter_id} integration state does not match its projection inputs`);
    invariant(plan.disabled_reason_code === (hardDisabled ? "one_or_more_source_bearing_projection_inputs_have_no_parity_proven_package_safe_executable" : null), `${plan.adapter_id} disabled reason does not fail closed`);
    invariant(plan.resolution_policy === (hardDisabled ? "deny_all_executable_resolution" : "resolve_only_without_instantiation"), `${plan.adapter_id} resolution policy does not fail closed`);
    invariant(!hardDisabled || plan.executable_assets.length === 0, `${plan.adapter_id} exposes executable assets while hard-disabled`);
    for (const asset of plan.runtime_assets) {
      assertExactKeys(asset, ["path", "sha256"], `${plan.adapter_id} contract runtime asset`);
      invariant(asset.path.startsWith("res://game/") && !asset.path.includes(".."), `${plan.adapter_id} contract runtime asset escapes the game package`);
      invariant(/^[0-9a-f]{64}$/u.test(asset.sha256), `${plan.adapter_id} contract runtime asset hash is malformed`);
    }
    for (const asset of plan.executable_assets) {
      assertExactKeys(asset, ["path", "resource_kind", "sha256"], `${plan.adapter_id} contract executable asset`);
      const runtimeAsset = plan.runtime_assets.find((candidate) => candidate.path === asset.path);
      invariant(runtimeAsset?.sha256 === asset.sha256, `${plan.adapter_id} executable asset is not an exact runtime-asset subset`);
      invariant(executableAssetKind(asset.path) === asset.resource_kind, `${plan.adapter_id} executable asset kind/root is not allowed`);
    }
    if (adapterById != null) {
      const adapter = adapterById.get(plan.adapter_id);
      invariant(adapter != null && adapter.receiver_key === plan.receiver_key && adapter.source_key === plan.source_key, `${plan.adapter_id} does not match its runtime registry adapter`);
      const expectedMode = registry.active_runtime_adapters.some((candidate) => candidate.adapter_id === plan.adapter_id)
        ? activeContentMode(adapter)
        : "legacy_adapter";
      invariant(plan.content_mode === expectedMode, `${plan.adapter_id} content mode drifted from its runtime adapter class`);
      invariant(equalStable(adapter.runtime_assets, plan.runtime_assets), `${plan.adapter_id} contract runtime assets drifted from the runtime registry`);
      const expectedDescriptors = adapter.runtime_asset_projections.map(projectionDescriptorId).sort();
      invariant(equalStable([...plan.projection_descriptor_ids].sort(), [...new Set(expectedDescriptors)].sort()), `${plan.adapter_id} projection descriptor membership drifted`);
    }
  }
  const observedProjectionOccurrences = [];
  for (const descriptor of contracts.projection_descriptors) {
    assertExactKeys(descriptor, [
      "consumer_adapter_ids",
      "descriptor_id",
      "disabled_reason_code",
      "execution_policy",
      "execution_state",
      "occurrence_projection_ids",
      "source_asset_sha256",
      "source_asset_type",
    ], `Facade runtime projection descriptor ${descriptor.descriptor_id}`);
    invariant(descriptor.descriptor_id === projectionDescriptorId(descriptor), `${descriptor.descriptor_id} is not derived from its pathless source identity`);
    invariant(descriptor.execution_state === "hard_disabled" && descriptor.execution_policy === "never_resolve_or_execute", `${descriptor.descriptor_id} is not hard-disabled`);
    invariant(descriptor.disabled_reason_code === "source_bearing_dependency_closure_requires_independent_package_safe_normalization", `${descriptor.descriptor_id} disabled reason drifted`);
    invariant(/^[0-9a-f]{64}$/u.test(descriptor.source_asset_sha256) && ["gd", "json"].includes(descriptor.source_asset_type), `${descriptor.descriptor_id} source identity is malformed or uses an unsupported future type`);
    invariant(Array.isArray(descriptor.consumer_adapter_ids) && descriptor.consumer_adapter_ids.length > 0, `${descriptor.descriptor_id} has no consumer adapter`);
    invariant(Array.isArray(descriptor.occurrence_projection_ids) && descriptor.occurrence_projection_ids.length > 0, `${descriptor.descriptor_id} has no projection occurrence`);
    assertUnique(descriptor.consumer_adapter_ids, `${descriptor.descriptor_id} consumers`);
    assertUnique(descriptor.occurrence_projection_ids, `${descriptor.descriptor_id} occurrences`);
    invariant(descriptor.consumer_adapter_ids.every((adapterId) => contracts.plans.some((plan) => plan.adapter_id === adapterId && plan.projection_descriptor_ids.includes(descriptor.descriptor_id))), `${descriptor.descriptor_id} consumer membership drifted`);
    observedProjectionOccurrences.push(...descriptor.occurrence_projection_ids);
  }
  assertUnique(observedProjectionOccurrences, "Facade runtime projection occurrences");
  invariant(observedProjectionOccurrences.length === EXPECTED_ADAPTER_CONTRACTS.disabled_projection_occurrences, "Facade runtime projection occurrence count drifted");
  if (registry != null) {
    const expectedOccurrences = [...registry.legacy_adapters, ...registry.active_runtime_adapters]
      .flatMap((adapter) => adapter.runtime_asset_projections.map((projection) => projection.projection_id))
      .sort();
    invariant(equalStable([...observedProjectionOccurrences].sort(), expectedOccurrences), "Facade runtime projection occurrences drifted from the registry");
  }
  assertRuntimeBoundary(contracts, "facade runtime adapter contracts");
}

function buildRuntimeRegistry(catalog, inputs, receiverByKey) {
  const packageAudit = [];
  const attachmentByReceiver = inventoryAttachmentByReceiver(inputs.inventory);
  const importedLegacyAdapters = catalog.legacy_adapters.map((seed) => importLegacyAdapter(
    seed,
    attachmentByReceiver.get(seed.receiver_key),
    receiverByKey.get(seed.receiver_key),
    packageAudit,
  ));
  const importedActiveAdapters = catalog.active_runtime_adapters.map((seed) => importActiveRuntimeAdapter(
    seed,
    receiverByKey.get(seed.receiver_key),
    inputs,
    packageAudit,
  ));
  const adapterBindingByReceiver = new Map([
    ...importedLegacyAdapters.map((adapter) => [adapter.receiver_key, {
      adapter_id: adapter.adapter_id,
      content_mode: "legacy_adapter",
    }]),
    ...importedActiveAdapters.map((adapter) => [adapter.receiver_key, {
      adapter_id: adapter.adapter_id,
      content_mode: activeContentMode(adapter),
    }]),
  ]);
  const captureByUnit = new Map(catalog.capture_contracts.map((capture) => [capture.unit_id, capture]));
  const identityAssertionsByUnit = new Map();
  for (const record of catalog.identity_evidence_records) {
    if (record.runtime_visibility !== "summary_only") continue;
    const summaries = identityAssertionsByUnit.get(record.unit_id) ?? [];
    summaries.push(runtimeIdentityAssertion(record));
    identityAssertionsByUnit.set(record.unit_id, summaries);
  }
  const runtimeUnits = catalog.units.map((unit) => {
    const directReceivers = unit.receiver_keys.map((receiverKey) => runtimeReceiverBinding(
      receiverKey,
      receiverByKey.get(receiverKey),
      expectedDirectSource(unit, receiverKey),
      adapterBindingByReceiver.get(receiverKey),
    ));
    return {
      acceptance_records: unit.acceptance_records.map(runtimeAcceptanceRecord),
      active_runtime_adapter_ids: directReceivers
        .filter((receiver) => ["active_building_1_hero", "active_building_3_hero", "active_isle_house_variant_c", "active_navy_chapel_187_paired_replacement", "active_d1_b201_host_partition_attachment", "active_d1_b225_host_partition_attachment", "active_d2_1441_paired_replacement", "active_d2_1439_paired_replacement", "active_d2_1444_paired_replacement", ...D5_BATCH_ACCEPTED.map((d) => d.mode)].includes(receiver.runtime_content_mode))
        .map((receiver) => receiver.runtime_adapter_id),
      capture_contract: runtimeCaptureContract(captureByUnit.get(unit.unit_id)),
      claim_status: unit.claim_status,
      direct_receivers: directReceivers,
      identity: unit.identity,
      identity_assertions: identityAssertionsByUnit.get(unit.unit_id) ?? [],
      legacy_adapter_ids: unit.legacy_adapter_ids,
      protected_scopes: unit.protected_scopes.map((scope) => ({
        receiver_key: scope.receiver_key,
        run_indices: scope.run_indices,
      })),
      recognition_cues: unit.recognition_cues.map((cue) => ({
        complete_motif: cue.complete_motif,
        cue_id: cue.cue_id,
        cue_kind: cue.cue_kind,
        evidence_class: cue.evidence_class,
        receiver_key: cue.receiver_key,
        reference_ids: cue.reference_ids,
        run_indices: cue.run_indices,
      })),
      recognition_contract: {
        authored_cue_count: unit.recognition_cues.length,
        authored_reference_count: unit.reference_records.length,
        capture_status: captureByUnit.get(unit.unit_id)?.status ?? "unconfigured",
        game_only_cues_do_not_prove_real_world_recognition: true,
        reference_state: unit.reference_state,
      },
      runtime_content_mode: unitRuntimeContentMode(directReceivers),
      source_records: unit.source_records,
      unit_id: unit.unit_id,
      unit_kind: unit.unit_kind,
    };
  });
  const totals = claimTotals(runtimeUnits);
  const acceptedReferenceUnitIds = runtimeUnits
    .filter((unit) => unit.claim_status.reference_recognizable === "accepted")
    .map((unit) => unit.unit_id)
    .sort();
  const adapterContracts = buildAdapterContracts(catalog, importedLegacyAdapters, importedActiveAdapters);
  const adapterContractsSha256 = sha256Bytes(stableJson(adapterContracts));
  const registry = {
    adapter_contract: {
      path: `res://${PATHS.adapterContracts}`,
      schema_version: ADAPTER_CONTRACT_SCHEMA,
      sha256: adapterContractsSha256,
    },
    build_contract: {
      authoring_catalog_sha256: sha256File(absolute(PATHS.catalog)),
      compiler_version: COMPILER_VERSION,
      generated_content_sha256: inputs.manifest.content_sha256,
      generated_manifest_sha256: inputs.manifestSha256,
      inventory_sha256: inputs.inventorySha256,
      runtime_discovery_dependency: false,
    },
    claim_totals: totals,
    claim_vocabulary: CLAIM_VOCABULARY,
    counts: {
      active_runtime_adapter_receivers: importedActiveAdapters.length,
      composite_units: runtimeUnits.filter((unit) => unit.unit_kind === "composite_building").length,
      direct_wall_receivers: runtimeUnits.flatMap((unit) => unit.direct_receivers).length,
      identity_assertion_summaries: runtimeUnits.flatMap((unit) => unit.identity_assertions).length,
      legacy_adapter_receivers: importedLegacyAdapters.length,
      recognition_units: runtimeUnits.length,
      runtime_adapter_receivers: adapterBindingByReceiver.size,
      source_record_memberships: runtimeUnits.flatMap((unit) => unit.source_records).length,
      standalone_units: runtimeUnits.filter((unit) => unit.unit_kind === "standalone_building").length,
      visible_wall_runs: runtimeUnits.flatMap((unit) => unit.direct_receivers).reduce((sum, receiver) => sum + receiver.run_count, 0),
    },
    compatibility_contract: {
      catalog_schema_version: CATALOG_SCHEMA,
      compiler_version: COMPILER_VERSION,
      forward_compatible: false,
      loader_api_version: LOADER_API_VERSION,
      unknown_version_policy: UNKNOWN_VERSION_POLICY,
    },
    active_runtime_adapters: importedActiveAdapters,
    legacy_adapters: importedLegacyAdapters,
    recognition_metric: {
      accepted_physical_unit_ids: acceptedReferenceUnitIds,
      denominator: EXPECTED.recognition_units,
      denominator_kind: "immutable_physical_recognition_units",
      display: `${acceptedReferenceUnitIds.length}/${EXPECTED.recognition_units}`,
      isle_house_non_numerator_source_keys: [...ISLE_HOUSE_PARTS],
      numerator: acceptedReferenceUnitIds.length,
      rollup_policy: "one_claim_per_physical_recognition_unit",
    },
    registry_id: CATALOG_ID,
    schema_version: RUNTIME_SCHEMA,
    units: runtimeUnits,
  };
  assertRuntimeBoundary(registry);
  validateAdapterContracts(adapterContracts, registry);
  return { adapterContracts, packageAudit, registry };
}

function assertRuntimeBoundary(value, label = "runtime registry") {
  if (typeof value === "string") {
    invariant(!value.includes("discovery/"), `${label} leaks a discovery path`);
    invariant(!value.includes("evidence/"), `${label} leaks an evidence path`);
    invariant(!value.includes("/Users/") && !value.includes("/Volumes/"), `${label} leaks an absolute source path`);
    invariant(!/https?:\/\//u.test(value), `${label} leaks a reference URL`);
    return;
  }
  if (Array.isArray(value)) {
    value.forEach((child, index) => assertRuntimeBoundary(child, `${label}[${index}]`));
    return;
  }
  if (value != null && typeof value === "object") {
    for (const [key, child] of Object.entries(value)) assertRuntimeBoundary(child, `${label}.${key}`);
  }
}

function assertRuntimeAssetClosures(registry) {
  const adapters = [...registry.legacy_adapters, ...registry.active_runtime_adapters];
  assertUnique(adapters.map((adapter) => adapter.receiver_key), "Runtime adapter receiver keys");
  for (const adapter of adapters) {
    assertUnique(adapter.runtime_assets.map((asset) => asset.path), `${adapter.adapter_id} runtime asset paths`);
    assertUnique(adapter.runtime_asset_projections.map((projection) => projection.projection_id), `${adapter.adapter_id} runtime projection IDs`);
    for (const asset of adapter.runtime_assets) {
      assertExactKeys(asset, ["path", "sha256"], `${adapter.adapter_id} runtime asset`);
      invariant(asset.path.startsWith("res://game/"), `${adapter.adapter_id} runtime asset is not a game-package path`);
      invariant(/^[0-9a-f]{64}$/u.test(asset.sha256), `${adapter.adapter_id} runtime asset hash is malformed: ${asset.path}`);
      const audit = inspectRuntimeAssetClosure(asset.path.slice("res://".length));
      invariant(audit.closure_clean, `${adapter.adapter_id} runtime asset dependency closure contains a source-only path or URL: ${asset.path}`);
      invariant(audit.direct_asset_sha256 === asset.sha256, `${adapter.adapter_id} runtime asset hash drifted: ${asset.path}`);
    }
    for (const projection of adapter.runtime_asset_projections) {
      assertExactKeys(projection, [
        "package_contract",
        "projection_id",
        "source_asset_sha256",
        "source_asset_type",
      ], `${adapter.adapter_id} runtime projection`);
      invariant(projection.package_contract === "sanitized_adapter_metadata_summary_only", `${adapter.adapter_id} runtime projection contract drifted`);
      invariant(/^runtime-projection:[0-9a-f]{64}$/u.test(projection.projection_id), `${adapter.adapter_id} runtime projection ID is malformed`);
      invariant(/^[0-9a-f]{64}$/u.test(projection.source_asset_sha256), `${adapter.adapter_id} runtime projection source hash is malformed`);
      invariant(/^[a-z0-9]+$/u.test(projection.source_asset_type), `${adapter.adapter_id} runtime projection source type is malformed`);
    }
  }
}

function validateRuntimeRegistry(registry, adapterContracts = null) {
  invariant(Array.isArray(registry.units), "Runtime registry units are missing");
  invariant(Array.isArray(registry.legacy_adapters), "Runtime registry legacy adapters are missing");
  invariant(Array.isArray(registry.active_runtime_adapters), "Runtime registry active adapters are missing");
  invariant(registry.schema_version === RUNTIME_SCHEMA, "Runtime registry schema is unknown or forward-incompatible");
  invariant(equalStable(registry.compatibility_contract, {
    catalog_schema_version: CATALOG_SCHEMA,
    compiler_version: COMPILER_VERSION,
    forward_compatible: false,
    loader_api_version: LOADER_API_VERSION,
    unknown_version_policy: UNKNOWN_VERSION_POLICY,
  }), "Runtime registry compatibility contract drifted or requests an unsupported future version");
  invariant(equalStable(registry.adapter_contract, {
    path: `res://${PATHS.adapterContracts}`,
    schema_version: ADAPTER_CONTRACT_SCHEMA,
    sha256: registry.adapter_contract?.sha256,
  }) && /^[0-9a-f]{64}$/u.test(registry.adapter_contract.sha256), "Runtime registry adapter-contract reference is invalid");
  invariant(registry.counts.recognition_units === EXPECTED.recognition_units, "Runtime registry unit count drifted");
  invariant(registry.counts.standalone_units === EXPECTED.standalone_units, "Runtime registry standalone count drifted");
  invariant(registry.counts.composite_units === EXPECTED.composite_units, "Runtime registry composite count drifted");
  invariant(registry.counts.source_record_memberships === EXPECTED.source_records, "Runtime registry source membership count drifted");
  invariant(registry.counts.direct_wall_receivers === EXPECTED.direct_wall_receivers, "Runtime registry receiver count drifted");
  invariant(registry.counts.visible_wall_runs === EXPECTED.visible_wall_runs, "Runtime registry wall-run count drifted");
  invariant(registry.counts.legacy_adapter_receivers === EXPECTED.legacy_adapter_receivers, "Runtime registry legacy adapter count drifted");
  invariant(registry.counts.active_runtime_adapter_receivers === EXPECTED.active_runtime_adapter_receivers, "Runtime registry active adapter count drifted");
  invariant(registry.counts.runtime_adapter_receivers === EXPECTED.runtime_adapter_receivers, "Runtime registry combined adapter count drifted");
  invariant(registry.legacy_adapters.length === EXPECTED.legacy_adapter_receivers, "Runtime registry legacy adapter array length drifted");
  invariant(registry.active_runtime_adapters.length === EXPECTED.active_runtime_adapter_receivers, "Runtime registry active adapter array length drifted");
  invariant(registry.counts.identity_assertion_summaries === registry.units.flatMap((unit) => unit.identity_assertions).length, "Runtime identity-assertion count drifted");
  invariant(equalStable(registry.claim_totals, claimTotals(registry.units)), "Runtime claim totals do not equal the physical-unit rollup");
  const acceptedRuntimeUnitIds = registry.units
    .filter((unit) => unit.claim_status.reference_recognizable === "accepted")
    .map((unit) => unit.unit_id)
    .sort();
  invariant(equalStable(acceptedRuntimeUnitIds, [...ACCEPTED_REFERENCE_UNIT_IDS].sort()), "Runtime accepted physical-unit set drifted");
  for (const unit of registry.units) {
    invariant(Array.isArray(unit.acceptance_records), `${unit.unit_id} runtime acceptance records are missing`);
    for (const record of unit.acceptance_records) validateAcceptanceReceipt(unit, record);
  }
  const runtimeUnitById = new Map(registry.units.map((unit) => [unit.unit_id, unit]));
  for (const adapter of registry.active_runtime_adapters) {
    assertExactKeys(adapter, [
      "accepted_run_scopes",
      "active_receiver_scope",
      "active_runtime_contract",
      "adapter_id",
      "attachment_kind",
      "content_classification",
      "package_integration_state",
      "receiver_key",
      "recognition_acceptance_authority",
      "recognition_acceptance_status",
      "recognition_claim_effect",
      "review_status",
      "review_status_scope",
      "runtime_asset_projections",
      "runtime_assets",
      "runtime_content_mode",
      "source_key",
      "state",
      "whole_building_recognizability_imported",
    ], `Active runtime adapter ${adapter.adapter_id}`);
    const expectedUnitId = ACTIVE_ADAPTER_UNIT_BY_RECEIVER[adapter.receiver_key];
    const unit = runtimeUnitById.get(expectedUnitId);
    invariant(unit != null && unit.direct_receivers.some((receiver) => receiver.receiver_key === adapter.receiver_key), `${adapter.adapter_id} does not cross-link to its exact physical recognition unit`);
    invariant(adapter.review_status === ACTIVE_ADAPTER_REVIEW_STATUS_BY_RECEIVER[adapter.receiver_key], `${adapter.adapter_id} review status is not an exact allowed provenance status`);
    invariant(adapter.review_status_scope === ACTIVE_REVIEW_STATUS_SCOPE, `${adapter.adapter_id} review status scope does not isolate runtime-asset original-detail provenance`);
    invariant(adapter.recognition_acceptance_authority === ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY, `${adapter.adapter_id} recognition authority does not belong to the physical-unit claim and independent receipt`);
    invariant(adapter.recognition_acceptance_status === unit.claim_status.reference_recognizable && adapter.recognition_acceptance_status === "accepted", `${adapter.adapter_id} recognition acceptance status does not equal its accepted physical-unit claim`);
    invariant(unit.acceptance_records.some((record) => record.review_kind === "independent_reference_recognition" && record.status === "accept"), `${adapter.adapter_id} physical recognition unit lacks an independent acceptance receipt`);
  }
  invariant(registry.claim_totals.receiver_complete.verified === EXPECTED.recognition_units, "Not every unit is receiver-complete");
  invariant(registry.claim_totals.game_distinctive.accepted === 0, "Recognition acceptance must not import game-distinctive acceptance");
  invariant(registry.claim_totals.reference_recognizable.accepted === ACCEPTED_REFERENCE_UNIT_IDS.length, "Runtime reference-recognizable numerator must equal the accepted physical-unit list");
  invariant(registry.claim_totals.as_built_fidelity.claimed === 0 && registry.claim_totals.as_built_fidelity.limited === 0, "Recognition acceptance must not import as-built fidelity");
  invariant(equalStable(registry.recognition_metric, {
    accepted_physical_unit_ids: [...ACCEPTED_REFERENCE_UNIT_IDS].sort(),
    denominator: EXPECTED.recognition_units,
    denominator_kind: "immutable_physical_recognition_units",
    display: `${ACCEPTED_REFERENCE_UNIT_IDS.length}/${EXPECTED.recognition_units}`,
    isle_house_non_numerator_source_keys: [...ISLE_HOUSE_PARTS],
    numerator: ACCEPTED_REFERENCE_UNIT_IDS.length,
    rollup_policy: "one_claim_per_physical_recognition_unit",
  }), "Runtime physical-entity recognition metric drifted from the accepted-unit rollup");
  invariant(registry.legacy_adapters.every((adapter) => adapter.whole_building_recognizability_imported === false && adapter.recognition_claim_effect === "none"), "Legacy adapter improperly grants recognizability");
  invariant(registry.active_runtime_adapters.every((adapter) => adapter.whole_building_recognizability_imported === false && adapter.recognition_claim_effect === "none"), "Active runtime adapter improperly grants recognizability");
  invariant(registry.units.flatMap((unit) => unit.identity_assertions).every((assertion) => assertion.frozen_value_preserved === true), "Runtime identity assertion silently overwrites frozen identity");
  const composite = registry.units.filter((unit) => unit.unit_kind === "composite_building");
  invariant(composite.length === 1 && composite[0].unit_id === unitId(ISLE_HOUSE_PARENT), "Runtime composite unit identity drifted");
  invariant(composite[0].source_records.length === 3 && composite[0].direct_receivers.length === 2, "Runtime composite unit must model three source records and two receivers");
  const highReceiver = composite[0].direct_receivers.find((receiver) => receiver.receiver_key === "building-composite:w1249412094:w1282547786:wall");
  const lowReceiver = composite[0].direct_receivers.find((receiver) => receiver.receiver_key === "building-composite:w1249412094:w1282547787:wall");
  invariant(highReceiver?.runtime_content_mode === "legacy_adapter", "Isle House high receiver lost its legacy adapter state");
  invariant(lowReceiver?.runtime_content_mode === "active_isle_house_variant_c" && lowReceiver.runtime_adapter_id === isleHouseActiveAdapterId(ISLE_HOUSE_LOW_WALL), "Isle House low receiver is not bound to its exact active Variant C adapter");
  invariant(composite[0].runtime_content_mode === "mixed_legacy_high_and_active_variant_c_low", "Isle House unit collapses its receiver-specific accepted live state");
  invariant(composite[0].claim_status.reference_recognizable === "accepted" && composite[0].acceptance_records.some((record) => record.review_receipt_sha256 === ISLE_HOUSE_LIVE_REVIEW_RECEIPT_SHA256), "Isle House parent lacks its exact independent live acceptance receipt");
  invariant(!registry.units.some((unit) => ISLE_HOUSE_PARTS.map(unitId).includes(unit.unit_id)), "Isle House part receiver records entered the recognition numerator as units");
  const building1Unit = registry.units.find((unit) => unit.unit_id === unitId(BUILDING_1_SOURCE));
  const towerUnit = registry.units.find((unit) => unit.unit_id === unitId(BUILDING_1_TOWER_SOURCE));
  const building3Unit = registry.units.find((unit) => unit.unit_id === unitId(BUILDING_3_SOURCE));
  const navyChapelUnit = registry.units.find((unit) => unit.unit_id === unitId(NAVY_CHAPEL_SOURCE));
  const d1B201Unit = registry.units.find((unit) => unit.unit_id === unitId(D1_B201_SOURCE));
  const d1B225Unit = registry.units.find((unit) => unit.unit_id === unitId(D1_B225_SOURCE));
  const d21441Unit = registry.units.find((unit) => unit.unit_id === unitId(D2_1441_SOURCE));
  const d21439Unit = registry.units.find((unit) => unit.unit_id === unitId(D2_1439_SOURCE));
  const d21444Unit = registry.units.find((unit) => unit.unit_id === unitId(D2_1444_SOURCE));
  invariant(building1Unit != null && towerUnit != null && building1Unit !== towerUnit, "Building 1 and observation tower physical units were collapsed");
  invariant(building1Unit.direct_receivers[0].runtime_content_mode === "active_building_1_hero", "Building 1 wall is not bound to the active hero adapter");
  invariant(towerUnit.direct_receivers[0].runtime_content_mode === "active_building_1_hero", "Observation tower wall is not bound to the active hero adapter");
  invariant(building1Unit.legacy_adapter_ids.length === 0 && building1Unit.active_runtime_adapter_ids.length === 1, "Building 1 unit retains obsolete or missing adapter membership");
  invariant(towerUnit.legacy_adapter_ids.length === 0 && towerUnit.active_runtime_adapter_ids.length === 1, "Observation tower unit retains obsolete or missing adapter membership");
  invariant(building3Unit?.direct_receivers[0]?.runtime_content_mode === "active_building_3_hero" && building3Unit.active_runtime_adapter_ids.length === 1 && building3Unit.legacy_adapter_ids.length === 0, "Building 3 wall is not bound exclusively to the active wall/roof hero adapter");
  invariant(navyChapelUnit?.direct_receivers[0]?.runtime_content_mode === "active_navy_chapel_187_paired_replacement" && navyChapelUnit.active_runtime_adapter_ids.length === 1 && navyChapelUnit.legacy_adapter_ids.length === 0, "Navy Chapel wall is not bound exclusively to the active paired wall/roof replacement");
  invariant(navyChapelUnit.claim_status.reference_recognizable === "accepted" && navyChapelUnit.acceptance_records.some((record) => record.review_receipt_sha256 === NAVY_CHAPEL_LIVE_REVIEW_RECEIPT_SHA256), "Navy Chapel physical unit lacks its exact independent live acceptance receipt");
  invariant(d1B201Unit?.direct_receivers[0]?.runtime_content_mode === "active_d1_b201_host_partition_attachment" && d1B201Unit.active_runtime_adapter_ids.length === 1 && d1B201Unit.legacy_adapter_ids.length === 0, "D1 B201 wall is not bound exclusively to the active host-partition attachment");
  invariant(d1B201Unit.claim_status.reference_recognizable === "accepted" && d1B201Unit.acceptance_records.some((record) => record.review_receipt_sha256 === D1_B201_LIVE_REVIEW_RECEIPT_SHA256), "D1 B201 physical unit lacks its exact independent live acceptance receipt");
  invariant(d1B225Unit?.direct_receivers[0]?.runtime_content_mode === "active_d1_b225_host_partition_attachment" && d1B225Unit.active_runtime_adapter_ids.length === 1 && d1B225Unit.legacy_adapter_ids.length === 0, "D1 B225 wall is not bound exclusively to the active host-partition attachment");
  invariant(d1B225Unit.claim_status.reference_recognizable === "accepted" && d1B225Unit.acceptance_records.some((record) => record.review_receipt_sha256 === D1_B225_LIVE_REVIEW_RECEIPT_SHA256 && record.evidence_manifest_sha256 === D1_B225_EVIDENCE_MANIFEST_SHA256 && record.evidence_tree_sha256 === D1_B225_EVIDENCE_TREE_SHA256 && record.capture_time_recognition_metric === "7/213" && record.numerator_effect === 1), "D1 B225 physical unit lacks its exact frozen production/review/+1 acceptance authority");
  invariant(d21441Unit?.direct_receivers[0]?.runtime_content_mode === "active_d2_1441_paired_replacement" && d21441Unit.runtime_content_mode === "all_receivers_active_d2_1441_paired_replacement" && d21441Unit.active_runtime_adapter_ids.length === 1 && d21441Unit.legacy_adapter_ids.length === 0, "D2 1441 wall is not bound exclusively to the active paired wall/roof replacement");
  invariant(d21439Unit?.direct_receivers[0]?.runtime_content_mode === "active_d2_1439_paired_replacement" && d21439Unit.runtime_content_mode === "all_receivers_active_d2_1439_paired_replacement" && d21439Unit.active_runtime_adapter_ids.length === 1 && d21439Unit.legacy_adapter_ids.length === 0, "D2 1439 wall is not bound exclusively to the active paired wall/roof replacement");
  invariant(d21444Unit?.direct_receivers[0]?.runtime_content_mode === "active_d2_1444_paired_replacement" && d21444Unit.runtime_content_mode === "all_receivers_active_d2_1444_paired_replacement" && d21444Unit.active_runtime_adapter_ids.length === 1 && d21444Unit.legacy_adapter_ids.length === 0, "D2 1444 wall is not bound exclusively to the active paired wall/roof replacement");
  invariant(d21441Unit.claim_status.reference_recognizable === "accepted" && d21441Unit.acceptance_records.length === 1 && equalStable(d21441Unit.acceptance_records[0], d21441AcceptanceRecord()), "D2 1441 physical unit lacks its exact seven-artifact frozen production/review/+1 acceptance authority");
  invariant(d21439Unit.claim_status.reference_recognizable === "accepted" && d21439Unit.acceptance_records.length === 1 && equalStable(d21439Unit.acceptance_records[0], d21439AcceptanceRecord()), "D2 1439 physical unit lacks its exact seven-artifact frozen production/review/+1 acceptance authority");
  invariant(d21444Unit.claim_status.reference_recognizable === "accepted" && d21444Unit.acceptance_records.length === 1 && equalStable(d21444Unit.acceptance_records[0], d21444AcceptanceRecord()), "D2 1444 physical unit lacks its exact seven-artifact frozen production/review/+1 acceptance authority");
  invariant(registry.active_runtime_adapters.map((adapter) => adapter.receiver_key).sort().join("|") === [BUILDING_1_WALL, BUILDING_1_TOWER_WALL, BUILDING_3_WALL, ISLE_HOUSE_LOW_WALL, NAVY_CHAPEL_WALL, D1_B201_WALL, D1_B225_WALL, D2_1441_WALL, D2_1439_WALL, D2_1444_WALL, ...D5_BATCH_ACCEPTED.map((d) => d.wall)].sort().join("|"), "Active Building 1/Building 3/Isle House/Navy Chapel/D1 B201/D1 B225/D2 1441 adapter receiver set drifted");
  const building1Adapters = registry.active_runtime_adapters.filter((adapter) => [BUILDING_1_WALL, BUILDING_1_TOWER_WALL].includes(adapter.receiver_key));
  const expectedBuilding1RuntimeAssetPaths = BUILDING_1_RUNTIME_ASSET_PATHS.map((path) => `res://${path}`).sort();
  invariant(building1Adapters.every((adapter) =>
    adapter.attachment_kind === "active_building_1_hero_replacement" &&
    adapter.content_classification === "active_target_specific_hero_replacement" &&
    adapter.state === "active_runtime_target_specific_content" &&
    adapter.source_key === (adapter.receiver_key === BUILDING_1_WALL ? BUILDING_1_SOURCE : BUILDING_1_TOWER_SOURCE) &&
    adapter.active_receiver_scope?.coverage === "whole_direct_wall_receiver" &&
    adapter.active_runtime_contract?.config_summary?.target?.tower_remains_separately_reviewable === true &&
    adapter.active_runtime_contract?.public_front_config_sha256 === sha256File(absolute(BUILDING_1_PUBLIC_FRONT_CONFIG_PATH)) &&
    adapter.runtime_assets.length === 11 &&
    equalStable(adapter.runtime_assets.map((asset) => asset.path).sort(), expectedBuilding1RuntimeAssetPaths) &&
    adapter.runtime_assets.some((asset) => asset.path === `res://${BUILDING_1_PUBLIC_FRONT_CONFIG_PATH}` && asset.sha256 === sha256File(absolute(BUILDING_1_PUBLIC_FRONT_CONFIG_PATH)))
  ), "Active Building 1 hero adapter classification, receiver/source mapping, or exact 11-asset closure drifted");
  const building3Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === BUILDING_3_WALL);
  invariant(
    building3Adapter?.attachment_kind === "active_building_3_wall_roof_hero_replacement" &&
    building3Adapter.content_classification === "active_target_specific_hero_replacement" &&
    building3Adapter.state === "active_runtime_target_specific_content" &&
    building3Adapter.active_receiver_scope?.coverage === "whole_direct_wall_receiver" &&
    building3Adapter.active_runtime_contract?.adapter_sha256 === sha256File(absolute(BUILDING_3_MASSING_PATH)) &&
    building3Adapter.active_runtime_contract?.config_sha256 === sha256File(absolute(BUILDING_3_CONFIG_PATH)) &&
    building3Adapter.active_runtime_contract?.dispatch_sha256 === D2_1441_REVIEWED_WORLD_BUILDER_SHA256 &&
    equalStable(building3Adapter.active_runtime_contract?.behavior_contract, building3BehaviorContract()),
    "Active Building 3 dependency or wall/roof behavior parity contract drifted",
  );
  const isleHouseAdapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === ISLE_HOUSE_LOW_WALL);
  invariant(
    isleHouseAdapter?.attachment_kind === "active_isle_house_variant_c_low_part_replacement" &&
    isleHouseAdapter.content_classification === "active_target_specific_composite_part_replacement" &&
    isleHouseAdapter.state === "active_runtime_target_specific_content" &&
    isleHouseAdapter.active_receiver_scope?.coverage === "whole_direct_wall_receiver" &&
    isleHouseAdapter.active_runtime_contract?.adapter_sha256 === sha256File(absolute(ISLE_HOUSE_LIVE_ADAPTER_PATH)) &&
    isleHouseAdapter.active_runtime_contract?.config_sha256 === sha256File(absolute(ISLE_HOUSE_VARIANT_C_CONFIG_PATH)) &&
    isleHouseAdapter.active_runtime_contract?.dispatch_sha256 === D2_1441_REVIEWED_WORLD_BUILDER_SHA256 &&
    isleHouseAdapter.active_runtime_contract?.repair_factory_sha256 === sha256File(absolute(ISLE_HOUSE_REPAIR_FACTORY_PATH)) &&
    isleHouseAdapter.active_runtime_contract?.reviewed_factory_sha256 === sha256File(absolute(ISLE_HOUSE_REVIEWED_FACTORY_PATH)) &&
    equalStable(isleHouseAdapter.active_runtime_contract?.behavior_contract, isleHouseBehaviorContract()),
    "Active Isle House low receiver acceptance, dependency, or behavior parity contract drifted",
  );
  const navyChapelAdapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === NAVY_CHAPEL_WALL);
  invariant(
    navyChapelAdapter?.attachment_kind === "active_navy_chapel_187_paired_wall_roof_replacement" &&
    navyChapelAdapter.content_classification === "active_target_specific_paired_wall_roof_replacement" &&
    navyChapelAdapter.state === "active_runtime_target_specific_content" &&
    navyChapelAdapter.active_receiver_scope?.coverage === "whole_direct_wall_receiver" &&
    navyChapelAdapter.active_runtime_contract?.adapter_sha256 === sha256File(absolute(NAVY_CHAPEL_LIVE_ADAPTER_PATH)) &&
    navyChapelAdapter.active_runtime_contract?.config_sha256 === sha256File(absolute(NAVY_CHAPEL_CONFIG_PATH)) &&
    navyChapelAdapter.active_runtime_contract?.dispatch_sha256 === D2_1441_REVIEWED_WORLD_BUILDER_SHA256 &&
    navyChapelAdapter.active_runtime_contract?.prototype_sha256 === sha256File(absolute(NAVY_CHAPEL_PROTOTYPE_PATH)) &&
    equalStable(navyChapelAdapter.active_runtime_contract?.behavior_contract, navyChapelBehaviorContract()),
    "Active Navy Chapel acceptance, paired dependency, or ownership parity contract drifted",
  );
  const d1B201Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === D1_B201_WALL);
  invariant(
    d1B201Adapter?.attachment_kind === "active_d1_b201_receiver_host_partition_attachment" &&
    d1B201Adapter.content_classification === "active_target_specific_receiver_host_partition_plus_render_only_attachment" &&
    d1B201Adapter.state === "active_runtime_target_specific_content" &&
    d1B201Adapter.active_receiver_scope?.coverage === "whole_direct_wall_receiver" &&
    d1B201Adapter.active_receiver_scope?.run_count === 40 &&
    d1B201Adapter.active_runtime_contract?.adapter_sha256 === sha256File(absolute(D1_B201_LIVE_ADAPTER_PATH)) &&
    d1B201Adapter.active_runtime_contract?.config_sha256 === sha256File(absolute(D1_B201_CONFIG_PATH)) &&
    d1B201Adapter.active_runtime_contract?.dispatch_sha256 === D2_1441_REVIEWED_WORLD_BUILDER_SHA256 &&
    equalStable(d1B201Adapter.active_runtime_contract?.behavior_contract, d1B201BehaviorContract()),
    "Active D1 B201 acceptance, dependency, host-partition, or ownership parity contract drifted",
  );
  const d1B225Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === D1_B225_WALL);
  invariant(
    d1B225Adapter?.attachment_kind === "active_d1_b225_receiver_host_partition_attachment" &&
    d1B225Adapter.content_classification === "active_target_specific_receiver_host_partition_plus_render_only_attachment" &&
    d1B225Adapter.state === "active_runtime_target_specific_content" &&
    d1B225Adapter.active_receiver_scope?.coverage === "whole_direct_wall_receiver" &&
    d1B225Adapter.active_receiver_scope?.run_count === 14 &&
    d1B225Adapter.active_runtime_contract?.adapter_sha256 === sha256File(absolute(D1_B225_LIVE_ADAPTER_PATH)) &&
    d1B225Adapter.active_runtime_contract?.config_sha256 === sha256File(absolute(D1_B225_CONFIG_PATH)) &&
    d1B225Adapter.active_runtime_contract?.dispatch_sha256 === D2_1441_REVIEWED_WORLD_BUILDER_SHA256 &&
    equalStable(d1B225Adapter.active_runtime_contract?.behavior_contract, d1B225BehaviorContract()),
    "Active D1 B225 acceptance, dependency, host-partition, or ownership parity contract drifted",
  );
  const d21441Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === D2_1441_WALL);
  invariant(
    d21441Adapter?.adapter_id === d21441ActiveAdapterId(D2_1441_WALL) &&
    d21441Adapter.attachment_kind === "active_d2_1441_paired_wall_roof_replacement" &&
    d21441Adapter.content_classification === "active_target_specific_paired_wall_roof_replacement" &&
    d21441Adapter.runtime_content_mode === "active_d2_1441_paired_replacement" &&
    d21441Adapter.state === "active_runtime_target_specific_content" &&
    d21441Adapter.active_receiver_scope?.coverage === "whole_direct_wall_receiver" &&
    d21441Adapter.active_receiver_scope?.run_count === 16 &&
    d21441Adapter.active_runtime_contract?.adapter_sha256 === D2_1441_LIVE_ADAPTER_SHA256 &&
    d21441Adapter.active_runtime_contract?.config_sha256 === D2_1441_CONFIG_SHA256 &&
    d21441Adapter.active_runtime_contract?.dispatch_sha256 === D2_1441_REVIEWED_WORLD_BUILDER_SHA256 &&
    d21441Adapter.active_runtime_contract?.prototype_sha256 === sha256File(absolute(D2_1441_PROTOTYPE_PATH)) &&
    d21441Adapter.active_runtime_contract?.prototype_config_sha256 === sha256File(absolute(D2_1441_PROTOTYPE_CONFIG_PATH)) &&
    d21441Adapter.active_runtime_contract?.site_kit_sha256 === sha256File(absolute(D2_1441_SITE_KIT_PATH)) &&
    equalStable(d21441Adapter.active_runtime_contract?.behavior_contract, d21441BehaviorContract()),
    "Active D2 1441 acceptance, paired dependency, topology, or ownership parity contract drifted",
  );

  const d21439Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === D2_1439_WALL);
  invariant(
    d21439Adapter?.adapter_id === d21439ActiveAdapterId(D2_1439_WALL) &&
    d21439Adapter.attachment_kind === "active_d2_1439_paired_wall_roof_replacement" &&
    d21439Adapter.content_classification === "active_target_specific_paired_wall_roof_replacement" &&
    d21439Adapter.runtime_content_mode === "active_d2_1439_paired_replacement" &&
    d21439Adapter.state === "active_runtime_target_specific_content" &&
    d21439Adapter.active_receiver_scope?.coverage === "whole_direct_wall_receiver" &&
    d21439Adapter.active_receiver_scope?.run_count === 24 &&
    d21439Adapter.active_runtime_contract?.adapter_sha256 === D2_1439_LIVE_ADAPTER_SHA256 &&
    d21439Adapter.active_runtime_contract?.config_sha256 === D2_1439_CONFIG_SHA256 &&
    d21439Adapter.active_runtime_contract?.dispatch_sha256 === D2_1439_REVIEWED_WORLD_BUILDER_SHA256 &&
    d21439Adapter.active_runtime_contract?.prototype_sha256 === sha256File(absolute(D2_1439_PROTOTYPE_PATH)) &&
    d21439Adapter.active_runtime_contract?.prototype_config_sha256 === sha256File(absolute(D2_1439_PROTOTYPE_CONFIG_PATH)) &&
    d21439Adapter.active_runtime_contract?.site_kit_sha256 === sha256File(absolute(D2_1439_SITE_KIT_PATH)) &&
    equalStable(d21439Adapter.active_runtime_contract?.behavior_contract, d21439BehaviorContract()),
    "Active D2 1439 acceptance, paired dependency, topology, or ownership parity contract drifted",
  );
  const d21444Adapter = registry.active_runtime_adapters.find((adapter) => adapter.receiver_key === D2_1444_WALL);
  invariant(
    d21444Adapter?.adapter_id === d21444ActiveAdapterId(D2_1444_WALL) &&
    d21444Adapter.attachment_kind === "active_d2_1444_paired_wall_roof_replacement" &&
    d21444Adapter.content_classification === "active_target_specific_paired_wall_roof_replacement" &&
    d21444Adapter.runtime_content_mode === "active_d2_1444_paired_replacement" &&
    d21444Adapter.state === "active_runtime_target_specific_content" &&
    d21444Adapter.active_receiver_scope?.coverage === "whole_direct_wall_receiver" &&
    d21444Adapter.active_receiver_scope?.run_count === 22 &&
    d21444Adapter.active_runtime_contract?.adapter_sha256 === D2_1444_LIVE_ADAPTER_SHA256 &&
    d21444Adapter.active_runtime_contract?.config_sha256 === D2_1444_CONFIG_SHA256 &&
    d21444Adapter.active_runtime_contract?.dispatch_sha256 === D2_1444_REVIEWED_WORLD_BUILDER_SHA256 &&
    d21444Adapter.active_runtime_contract?.prototype_sha256 === sha256File(absolute(D2_1444_PROTOTYPE_PATH)) &&
    d21444Adapter.active_runtime_contract?.prototype_config_sha256 === sha256File(absolute(D2_1444_PROTOTYPE_CONFIG_PATH)) &&
    d21444Adapter.active_runtime_contract?.site_kit_sha256 === sha256File(absolute(D2_1444_SITE_KIT_PATH)) &&
    equalStable(d21444Adapter.active_runtime_contract?.behavior_contract, d21444BehaviorContract()),
    "Active D2 1444 acceptance, paired dependency, topology, or ownership parity contract drifted",
  );
  for (const d of D5_BATCH_ACCEPTED) {
    const adapter = registry.active_runtime_adapters.find((a) => a.receiver_key === d.wall);
    const contract = adapter?.active_runtime_contract;
    invariant(adapter?.adapter_id === d.adapter_id && adapter.source_key === d.source && adapter.runtime_content_mode === d.mode && adapter.attachment_kind === (d.attachment_kind ?? `active_d5_${d.number}_paired_wall_roof_replacement`), `D5 ${d.number} active identity drifted`);
    invariant(adapter.active_receiver_scope.run_count === d.behavior.replacement_contract.mapped_public_run_indices.length + d.behavior.replacement_contract.protected_run_indices.length && adapter.active_receiver_scope.coverage === "whole_direct_wall_receiver" && adapter.accepted_run_scopes.length === 0 && adapter.runtime_asset_projections.length === 0, `D5 ${d.number} exact receiver/projection scope drifted`);
    invariant(contract && equalStable(contract.behavior_contract, d.behavior) && equalStable(contract.config_summary, d.config) && contract.adapter_sha256 === d.hashes.adapter && contract.config_sha256 === d.hashes.config && contract.dispatch_sha256 === D5_BATCH_BUILDER_SHA256 && contract.prototype_sha256 === d.hashes.factory && contract.prototype_config_sha256 === d.hashes.factory_config && contract.site_kit_sha256 === d.hashes.site_kit, `D5 ${d.number} acceptance, source, terrain, topology or ownership parity drifted`);
    invariant(equalStable(adapter.runtime_assets.map((a) => [a.path,a.sha256]).sort(), Object.entries(d.files).map(([key,path]) => [`res://${path}`, d.hashes[key]]).sort()), `D5 ${d.number} runtime dependency closure drifted`);
  }
  const currentTopologyOwners = registry.active_runtime_adapters.filter((adapter) => adapter.active_runtime_contract?.behavior_contract?.geometry_contract?.world_topology_scope === CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE);
  invariant(currentTopologyOwners.length === 1 && currentTopologyOwners[0].adapter_id === D5_BATCH_ACCEPTED.at(-1).adapter_id, "The final accepted D5 batch unit must be the sole current-integration topology authority");
  invariant(
    equalStable(
      building3Adapter.runtime_assets.map((asset) => asset.path).sort(),
      [BUILDING_3_MASSING_PATH, BUILDING_3_CONFIG_PATH, ...BUILDING_3_FACADE_ASSET_PATHS].map((path) => `res://${path}`).sort(),
    ) && building3Adapter.runtime_asset_projections.length === 0,
    "Active Building 3 runtime asset closure is incomplete or source-bearing",
  );
  invariant(
    equalStable(
      navyChapelAdapter.runtime_assets.map((asset) => asset.path).sort(),
      [NAVY_CHAPEL_LIVE_ADAPTER_PATH, NAVY_CHAPEL_CONFIG_PATH, ...NAVY_CHAPEL_RUNTIME_ASSET_PATHS].map((path) => `res://${path}`).sort(),
    ) && navyChapelAdapter.runtime_asset_projections.length === 0,
    "Active Navy Chapel runtime asset closure is incomplete or source-bearing",
  );
  invariant(
    equalStable(
      d1B201Adapter.runtime_assets.map((asset) => asset.path).sort(),
      [D1_B201_LIVE_ADAPTER_PATH, D1_B201_CONFIG_PATH, ...D1_B201_RUNTIME_ASSET_PATHS].map((path) => `res://${path}`).sort(),
    ) && d1B201Adapter.runtime_asset_projections.length === 0,
    "Active D1 B201 exact eight-asset runtime closure is incomplete or source-bearing",
  );
  invariant(
    equalStable(
      d1B225Adapter.runtime_assets.map((asset) => asset.path).sort(),
      [D1_B225_LIVE_ADAPTER_PATH, D1_B225_CONFIG_PATH, ...D1_B225_RUNTIME_ASSET_PATHS].map((path) => `res://${path}`).sort(),
    ) && d1B225Adapter.runtime_asset_projections.length === 0,
    "Active D1 B225 exact six-asset runtime closure is incomplete or source-bearing",
  );
  invariant(
    equalStable(
      d21441Adapter.runtime_assets.map((asset) => asset.path).sort(),
      [D2_1441_LIVE_ADAPTER_PATH, D2_1441_CONFIG_PATH, ...D2_1441_RUNTIME_ASSET_PATHS].map((path) => `res://${path}`).sort(),
    ) && d21441Adapter.runtime_asset_projections.length === 0,
    "Active D2 1441 exact thirteen-asset runtime closure is incomplete or source-bearing",
  );
  invariant(
    equalStable(
      d21439Adapter.runtime_assets.map((asset) => asset.path).sort(),
      [D2_1439_LIVE_ADAPTER_PATH, D2_1439_CONFIG_PATH, ...D2_1439_RUNTIME_ASSET_PATHS].map((path) => `res://${path}`).sort(),
    ) && d21439Adapter.runtime_asset_projections.length === 0,
    "Active D2 1439 exact thirteen-asset runtime closure is incomplete or source-bearing",
  );
  invariant(
    equalStable(
      d21444Adapter.runtime_assets.map((asset) => asset.path).sort(),
      [D2_1444_LIVE_ADAPTER_PATH, D2_1444_CONFIG_PATH, ...D2_1444_RUNTIME_ASSET_PATHS].map((path) => `res://${path}`).sort(),
    ) && d21444Adapter.runtime_asset_projections.length === 0,
    "Active D2 1444 exact thirteen-asset runtime closure is incomplete or source-bearing",
  );
  invariant(!stableJson(registry).includes("building_1_recognizable_facade") && !stableJson(registry).includes("building_1_recognizability_placements"), "Runtime registry retains obsolete Building 1 facade content");
  assertRuntimeBoundary(registry);
  assertRuntimeAssetClosures(registry);
  if (adapterContracts != null) {
    validateAdapterContracts(adapterContracts, registry);
    invariant(sha256Bytes(stableJson(adapterContracts)) === registry.adapter_contract.sha256, "Runtime registry adapter-contract hash drifted");
  }
}

function packageAuditSummary(packageAudit, registry) {
  const uniqueDirect = new Map();
  const uniqueClosure = new Map();
  for (const audit of packageAudit) {
    if (!uniqueDirect.has(audit.direct_asset_path)) uniqueDirect.set(audit.direct_asset_path, audit);
    for (const asset of audit.closure_assets) if (!uniqueClosure.has(asset.asset_path)) uniqueClosure.set(asset.asset_path, asset);
  }
  const runtimeReferenced = [...registry.legacy_adapters, ...registry.active_runtime_adapters]
    .flatMap((adapter) => adapter.runtime_assets.map((asset) => asset.path));
  return {
    adapter_asset_occurrence_count: packageAudit.length,
    clean_direct_asset_count: [...uniqueDirect.values()].filter((audit) => audit.closure_clean).length,
    dependency_closure_asset_count: uniqueClosure.size,
    dependency_closure_forbidden_asset_count: [...uniqueClosure.values()].filter((asset) => asset.violations.length > 0).length,
    direct_asset_count: uniqueDirect.size,
    projected_direct_asset_count: [...uniqueDirect.values()].filter((audit) => !audit.closure_clean).length,
    registry_json_clean: true,
    runtime_referenced_asset_count: new Set(runtimeReferenced).size,
    runtime_referenced_dependency_closure_clean: true,
    source_side_projection_audit: packageAudit.map((audit) => ({
      adapter_id: audit.adapter_id,
      closure_asset_count: audit.closure_assets.length,
      closure_violations: audit.closure_assets
        .filter((asset) => asset.violations.length > 0)
        .map((asset) => ({ asset_path: asset.asset_path, violations: asset.violations })),
      direct_asset_path: audit.direct_asset_path,
      direct_asset_sha256: audit.direct_asset_sha256,
      emitted_as: audit.closure_clean ? "runtime_asset" : "sanitized_runtime_summary",
    })),
  };
}

function buildReport(catalog, registry, adapterContracts, inputs, packageAudit) {
  const registrySerialized = stableJson(registry);
  const unresolvedUnits = catalog.units
    .filter((unit) => unit.reference_state === "identity_or_reference_research_required")
    .map((unit) => unit.unit_id);
  return {
    checks: [
      { check_id: "immutable_source_hashes", status: "pass" },
      { check_id: "source_records_partition_215", status: "pass" },
      { check_id: "physical_recognition_units_213", status: "pass" },
      { check_id: "direct_wall_receivers_214", status: "pass" },
      { check_id: "isle_house_composite_3_sources_2_receivers_1_unit", status: "pass" },
      { check_id: "wall_run_quad_contract_4971", status: "pass" },
      { check_id: "receiver_complete_213", status: "pass" },
      { check_id: "legacy_adapters_9_active_runtime_adapters_9_without_automatic_recognition_transfer", status: "pass" },
      { check_id: "building_1_and_tower_exact_current_hero_dispatch", status: "pass" },
      { check_id: "building_3_exact_current_wall_roof_facade_collision_landing_spray_parity", status: "pass" },
      { check_id: "isle_house_receiver_specific_high_legacy_low_variant_c_runtime_state", status: "pass" },
      { check_id: "navy_chapel_exact_current_paired_wall_roof_collision_landing_spray_parity", status: "pass" },
      { check_id: "d1_b201_pre_b225_host_partition_render_attachment_collision_spray_parity", status: "pass" },
      { check_id: "d1_b225_pre_d2_host_partition_render_attachment_collision_spray_parity", status: "pass" },
      { check_id: "d2_1441_historical_paired_wall_roof_evidence_topology_collision_landing_spray_parity", status: "pass" },
      { check_id: "d2_1439_accepted_paired_closed_recess_evidence_historical_topology_collision_spray_parity", status: "pass" },
      { check_id: "d2_1444_historical_paired_closed_recess_evidence_topology_collision_spray_parity", status: "pass" },
      { check_id: `reference_recognizable_physical_entity_rollup_exactly_${ACCEPTED_REFERENCE_UNIT_IDS.length}_of_${EXPECTED.recognition_units}`, status: "pass" },
      { check_id: "isle_house_composite_parent_counted_once_part_sources_never_counted", status: "pass" },
      { check_id: "acceptance_records_bound_to_exact_independent_review_receipts", status: "pass" },
      { check_id: "catalog_json_schema_document_and_instance_validation", status: "pass" },
      { check_id: "catalog_compiler_runtime_loader_versions_reject_unknown_forward_versions", status: "pass" },
      { check_id: ADAPTER_CONTRACT_CHECK_ID, status: "pass" },
      { check_id: "claim_dimensions_separated", status: "pass" },
      { check_id: "frozen_identity_preserved_external_assertions_separated", status: "pass" },
      { check_id: "runtime_registry_and_referenced_asset_closures_have_no_discovery_evidence_url_or_absolute_dependency", status: "pass" },
    ],
    claim_totals: registry.claim_totals,
    counts: registry.counts,
    identity_evidence: identityCounts(inputs.inventory, catalog.units),
    identity_assertions: {
      authoritative_correction_count: catalog.identity_evidence_records.filter((record) => record.evidence_class === "authoritative_correction").length,
      authoritative_current_identity_count: catalog.identity_evidence_records.filter((record) => record.evidence_class === "authoritative_current_identity").length,
      authoring_record_count: catalog.identity_evidence_records.length,
      currentness_claimed_count: catalog.identity_evidence_records.filter((record) => record.currentness_claimed).length,
      records: catalog.identity_evidence_records,
      runtime_summary_count: registry.counts.identity_assertion_summaries,
    },
    input_hashes: {
      active_building_1_hero_adapter_sha256: inputs.runtimeContracts.heroAdapterSha256,
      active_building_1_hero_config_sha256: inputs.runtimeContracts.heroConfigSha256,
      active_building_1_public_front_config_sha256: inputs.runtimeContracts.heroPublicFrontConfigSha256,
      active_building_1_returns_v2_acceptance_receipt_sha256: inputs.runtimeContracts.heroReturnsAcceptanceSha256,
      active_building_3_hero_adapter_sha256: inputs.runtimeContracts.building3MassingSha256,
      active_building_3_authoring_provenance_sha256: inputs.runtimeContracts.building3AuthoringProvenanceSha256,
      active_building_3_hero_config_sha256: inputs.runtimeContracts.building3ConfigSha256,
      active_isle_house_variant_c_adapter_sha256: inputs.runtimeContracts.isleHouseLiveAdapterSha256,
      active_isle_house_variant_c_config_sha256: inputs.runtimeContracts.isleHouseConfigSha256,
      active_isle_house_variant_c_live_review_receipt_sha256: ISLE_HOUSE_LIVE_REVIEW_RECEIPT_SHA256,
      active_isle_house_variant_c_repair_factory_sha256: inputs.runtimeContracts.isleHouseRepairFactorySha256,
      active_isle_house_variant_c_reviewed_factory_sha256: inputs.runtimeContracts.isleHouseReviewedFactorySha256,
      active_navy_chapel_187_adapter_sha256: inputs.runtimeContracts.navyChapelLiveAdapterSha256,
      active_navy_chapel_187_config_sha256: inputs.runtimeContracts.navyChapelConfigSha256,
      active_navy_chapel_187_live_review_receipt_sha256: NAVY_CHAPEL_LIVE_REVIEW_RECEIPT_SHA256,
      active_navy_chapel_187_prototype_sha256: inputs.runtimeContracts.navyChapelPrototypeSha256,
      active_d1_b201_adapter_sha256: inputs.runtimeContracts.d1B201LiveAdapterSha256,
      active_d1_b201_config_sha256: inputs.runtimeContracts.d1B201ConfigSha256,
      active_d1_b201_evidence_manifest_sha256: D1_B201_EVIDENCE_MANIFEST_SHA256,
      active_d1_b201_live_review_receipt_sha256: D1_B201_LIVE_REVIEW_RECEIPT_SHA256,
      active_d1_b225_adapter_sha256: inputs.runtimeContracts.d1B225LiveAdapterSha256,
      active_d1_b225_config_sha256: inputs.runtimeContracts.d1B225ConfigSha256,
      active_d1_b225_evidence_manifest_sha256: D1_B225_EVIDENCE_MANIFEST_SHA256,
      active_d1_b225_evidence_tree_sha256: D1_B225_EVIDENCE_TREE_SHA256,
      active_d1_b225_live_review_receipt_sha256: D1_B225_LIVE_REVIEW_RECEIPT_SHA256,
      active_d2_1441_adapter_sha256: inputs.runtimeContracts.d21441LiveAdapterSha256,
      active_d2_1439_adapter_sha256: D2_1439_LIVE_ADAPTER_SHA256,
      active_d2_1444_adapter_sha256: D2_1444_LIVE_ADAPTER_SHA256,
      active_d2_1439_config_sha256: D2_1439_CONFIG_SHA256,
      active_d2_1444_config_sha256: D2_1444_CONFIG_SHA256,
      active_d2_1439_evidence_tree_sha256: D2_1439_EVIDENCE_TREE_SHA256,
      active_d2_1444_evidence_tree_sha256: D2_1444_EVIDENCE_TREE_SHA256,
      active_d2_1439_review_receipt_sha256: D2_1439_VISUAL_REVIEW_RECEIPT_SHA256,
      active_d2_1444_review_receipt_sha256: D2_1444_VISUAL_REVIEW_RECEIPT_SHA256,
      active_d2_1441_config_sha256: inputs.runtimeContracts.d21441ConfigSha256,
      active_d2_1441_evidence_manifest_sha256: inputs.runtimeContracts.d21441EvidenceManifestSha256,
      active_d2_1441_evidence_tree_sha256: inputs.runtimeContracts.d21441EvidenceTree.sha256,
      active_d2_1441_mechanical_review_receipt_sha256: inputs.runtimeContracts.d21441MechanicalReviewSha256,
      active_d2_1441_motion_telemetry_manifest_sha256: inputs.runtimeContracts.d21441MotionTelemetryManifestSha256,
      active_d2_1441_package_verification_receipt_sha256: inputs.runtimeContracts.d21441PackageVerificationReceiptSha256,
      active_d2_1441_prototype_config_sha256: inputs.runtimeContracts.d21441PrototypeConfigSha256,
      active_d2_1441_prototype_sha256: inputs.runtimeContracts.d21441PrototypeSha256,
      active_d2_1441_site_kit_sha256: inputs.runtimeContracts.d21441SiteKitSha256,
      active_d2_1441_visual_motion_manifest_sha256: inputs.runtimeContracts.d21441VisualMotionManifestSha256,
      active_d2_1441_visual_review_receipt_sha256: inputs.runtimeContracts.d21441VisualReviewSha256,
      adapter_contracts_sha256: sha256Bytes(stableJson(adapterContracts)),
      facade_runtime_loader_sha256: sha256File(absolute(FACADE_RUNTIME_LOADER_PATH)),
      authoring_catalog_sha256: sha256File(absolute(PATHS.catalog)),
      catalog_schema_sha256: sha256File(absolute(PATHS.schema)),
      generated_content_sha256: inputs.manifest.content_sha256,
      generated_manifest_sha256: inputs.manifestSha256,
      receiver_inventory_sha256: inputs.inventorySha256,
      world_chunk_builder_sha256: inputs.runtimeContracts.acceptedWorldBuilderSha256,
    },
    legacy_adapter_receiver_keys: registry.legacy_adapters.map((adapter) => adapter.receiver_key),
    active_runtime_adapter_receiver_keys: registry.active_runtime_adapters.map((adapter) => adapter.receiver_key),
    next_integration_seam: "Use the topology-neutral facade registry loader API to query receiver plans. Package-safe plans include exact-current Building 1, Building 3, Navy Chapel, D1 B201, D1 B225, and D2 1441 dependencies. The exact-current Isle House Variant C receiver is represented truthfully but remains loader-hard-disabled because its reviewed executable inheritance closure includes three source-token-bearing inputs; keep every disabled plan non-executable until its projected inputs receive independently parity-proven package-safe normalization.",
    package_boundary: packageAuditSummary(packageAudit, registry),
    reference_dependencies: {
      identity_or_reference_research_required_unit_count: unresolvedUnits.length,
      unit_ids: unresolvedUnits,
      workflow: "Continue reference-ready units. After bounded autonomous research, add a narrow HUMAN.md dependency only when target identity or a target-identifiable observed region genuinely requires owner evidence.",
    },
    runtime_registry_sha256: sha256Bytes(registrySerialized),
    reference_recognition_metric: registry.recognition_metric,
    schema_version: REPORT_SCHEMA,
    scope_boundaries: [
      "The D2 1441 promotion preserves generated bytes while atomically replacing the supplied wall+roof pair with nine visual surfaces, two structural owners, one wall spray owner, and zero decorative collision or navigation owners.",
      "The unchanged D1 B201 attachment retains its pre-B225 735/950/964/66,636/466/466 parity receipt and D1 B225 retains its pre-D2 735/952/967/67,716/466/466 receipt, while D2 1441 retains historical post-B1 735/959/974/70,692/466/466 and D2 1439 retains historical 735/968/983/71,156/466/467; D2 1444 retains historical 735/977/992/71,828/466/468; Station48 owns current735/1023/1038/82,789/466/477 topology; D5 1317 retains pre-Station48 735/1018/1033/81,761/466/477 topology; 1308/1394 retain their measured quality-batch 735/1006/1021/79,913/466/474 scope. Prior 11/213 promotion evidence remains historical. These two existing-unit quality revisions were captured at 13/213 and add zero credit.",
      `${registry.legacy_adapters.length} legacy receivers and ${registry.active_runtime_adapters.length} exact-current active receiver adapters are represented without automatic recognition transfer from adapter metadata.`,
      "The version-pinned loader contract authorizes parsing and resource resolution only; it does not authorize node instantiation or world-construction dispatch.",
      `Exactly ${registry.recognition_metric.numerator} independently reviewed physical-building units are reference-recognizable; game distinctiveness and as-built fidelity remain separate and unaccepted.`,
      "D2 1441 contributes exactly one standalone physical-building claim bound to the frozen capture-time v8 static, telemetry, visual-motion, package, tree, mechanical-review, and visual-review hashes; its paired wall and roof never create a second receiver or numerator entry.",
      "D1 B225 contributes exactly one standalone physical-building claim bound to the frozen capture-time v7 production evidence tree, static manifest, and independent review receipt; its two decorative batches, one wall receiver, and protected roof never create extra units or numerator entries.",
      "D1 B201 contributes exactly one standalone physical-building claim; its six decorative batches, one wall receiver, and protected roof never create extra units or numerator entries.",
      "Navy Chapel contributes one standalone physical-building claim; its paired wall and roof behavior never creates a second receiver or numerator entry.",
      "Isle House contributes one parent physical-building claim; its high and low source receiver records never enter the numerator.",
      "The registry JSON and every emitted runtime asset dependency closure exclude discovery paths, evidence paths, reference URLs, and absolute workstation paths; contaminated current assets are represented only by hash-bound sanitized summaries.",
      "Evidence-backed identity corrections remain separate from immutable inventory identity; runtime summaries preserve both asserted and frozen values without source locators.",
    ],
    status: "pass",
  };
}

function compile(catalog, inputs) {
  const receiverByKey = loadWallReceivers(inputs.manifest);
  const derivedUnits = deriveUnitSeeds(inputs.inventory);
  validateCatalog(catalog, inputs, derivedUnits, receiverByKey);
  const { adapterContracts, packageAudit, registry } = buildRuntimeRegistry(catalog, inputs, receiverByKey);
  validateRuntimeRegistry(registry, adapterContracts);
  const report = buildReport(catalog, registry, adapterContracts, inputs, packageAudit);
  invariant(report.reference_dependencies.identity_or_reference_research_required_unit_count === 60, "Expected 60 remaining identity/reference research dependencies after accepting the separately researched Building 1 tower");
  return { adapterContracts, packageAudit, registry, report };
}

function writeOutput(relativePath, value) {
  writeFileSync(absolute(relativePath), stableJson(value), "utf8");
}

function assertCheckedIn(relativePath, value) {
  invariant(existsSync(absolute(relativePath)), `Missing checked-in generated artifact ${relativePath}`);
  const expected = stableJson(value);
  const actual = readFileSync(absolute(relativePath), "utf8");
  invariant(actual === expected, `${relativePath} is stale; run this compiler with --write`);
}

function parseArguments(arguments_) {
  const allowed = new Set(["--check", "--seed-catalog", "--write"]);
  for (const argument of arguments_) invariant(allowed.has(argument), `Unknown argument ${argument}`);
  const flags = new Set(arguments_);
  invariant(!(flags.has("--check") && flags.has("--write")), "--check and --write are mutually exclusive");
  invariant(!flags.has("--seed-catalog") || flags.has("--write"), "--seed-catalog requires --write");
  return {
    check: flags.has("--check") || !flags.has("--write"),
    seedCatalog: flags.has("--seed-catalog"),
    write: flags.has("--write"),
  };
}

function main() {
  const mode = parseArguments(process.argv.slice(2));
  const inputs = loadInputs();
  if (mode.seedCatalog) {
    invariant(!existsSync(absolute(PATHS.catalog)), `${PATHS.catalog} already exists; refusing to overwrite authored catalog state`);
    writeOutput(PATHS.catalog, buildSeedCatalog(inputs));
  }
  invariant(existsSync(absolute(PATHS.catalog)), `Missing ${PATHS.catalog}; bootstrap once with --seed-catalog --write`);
  invariant(existsSync(absolute(PATHS.schema)), `Missing ${PATHS.schema}`);
  const catalog = readJson(PATHS.catalog);
  const { adapterContracts, registry, report } = compile(catalog, inputs);
  if (mode.write) {
    writeOutput(PATHS.adapterContracts, adapterContracts);
    writeOutput(PATHS.registry, registry);
    writeOutput(PATHS.report, report);
  } else if (mode.check) {
    assertCheckedIn(PATHS.adapterContracts, adapterContracts);
    assertCheckedIn(PATHS.registry, registry);
    assertCheckedIn(PATHS.report, report);
  }
  process.stdout.write(stableJson({
    active_runtime_adapter_receivers: report.counts.active_runtime_adapter_receivers,
    adapter_contract_disabled_receivers: adapterContracts.counts.disabled_adapter_receivers,
    adapter_contract_package_safe_receivers: adapterContracts.counts.package_safe_adapter_receivers,
    adapter_contract_sha256: report.input_hashes.adapter_contracts_sha256,
    catalog_sha256: sha256File(absolute(PATHS.catalog)),
    direct_wall_receivers: report.counts.direct_wall_receivers,
    identity_or_reference_research_required_units: report.reference_dependencies.identity_or_reference_research_required_unit_count,
    identity_assertion_summaries: report.counts.identity_assertion_summaries,
    legacy_adapter_receivers: report.counts.legacy_adapter_receivers,
    mode: mode.write ? (mode.seedCatalog ? "seed-and-write" : "write") : "check",
    recognition_units: report.counts.recognition_units,
    reference_recognizable_metric: report.reference_recognition_metric.display,
    registry_sha256: report.runtime_registry_sha256,
    runtime_adapter_receivers: report.counts.runtime_adapter_receivers,
    sanitized_runtime_asset_projections: report.package_boundary.projected_direct_asset_count,
    source_records: report.counts.source_record_memberships,
    status: "pass",
    visible_wall_runs: report.counts.visible_wall_runs,
  }));
}

const invokedPath = process.argv[1] == null ? "" : resolve(process.argv[1]);
if (invokedPath === fileURLToPath(import.meta.url)) main();

export {
  ADAPTER_CONTRACT_CHECK_ID,
  ADAPTER_CONTRACT_SCHEMA,
  CATALOG_SCHEMA,
  COMPILER_VERSION,
  EXPECTED,
  EXPECTED_ADAPTER_CONTRACTS,
  LOADER_API_VERSION,
  PATHS,
  REPORT_SCHEMA,
  RUNTIME_SCHEMA,
  assertRuntimeAssetClosures,
  buildSeedCatalog,
  compile,
  inspectRuntimeAssetClosure,
  loadInputs,
  validateAdapterContracts,
  validateActiveHeroDispatch,
  validateCurrentWorldBuilderDispatch,
  validateRuntimeRegistry,
};
