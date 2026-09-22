class_name FacadeRuntimeRegistryLoader
extends RefCounted

const DEFAULT_REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const DEFAULT_ADAPTER_CONTRACT_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const DEFAULT_LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const REGISTRY_SCHEMA_VERSION := "ti.facade-runtime-registry/26"
const ADAPTER_CONTRACT_SCHEMA_VERSION := "ti.facade-runtime-adapter-contracts/25"
const CATALOG_SCHEMA_VERSION := "ti.facade-recognition-catalog/26"
const COMPILER_VERSION := "1.25.0"
const LOADER_API_VERSION := "ti.facade-runtime-registry-loader/25"
const UNKNOWN_VERSION_POLICY := "reject"
const EXPECTED_UNIT_COUNT := 213
const EXPECTED_RECEIVER_COUNT := 214
const EXPECTED_SOURCE_RECORD_COUNT := 215
const EXPECTED_ADAPTER_COUNT := 34
const EXPECTED_READY_ADAPTER_COUNT := 28
const EXPECTED_DISABLED_ADAPTER_COUNT := 6
const EXPECTED_PROJECTION_DESCRIPTOR_COUNT := 13
const EXPECTED_PROJECTION_OCCURRENCE_COUNT := 13
const EXPECTED_REFERENCE_RECOGNIZABLE_COUNT := 26
const EXPECTED_REFERENCE_RECOGNIZABLE_UNIT_IDS := [
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
	"physical-building:r19685981",
	"physical-building:w96215661",
	"physical-building:w96215653",
	"physical-building:w96215651",
	"physical-building:w96215649",
	"physical-building:w96215652",
	"physical-building:w96215658",
	"physical-building:w96215677",
	"physical-building:w96215680",
	"physical-building:w96215672",
	"physical-building:w96215669",
]
const ACTIVE_REVIEW_STATUS_SCOPE := "runtime_asset_original_detail_provenance_only_not_reference_recognition"
const ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY := "physical_unit_claim_and_independent_acceptance_record"
const PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_b201_integration_live_parity"
const PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_b225_integration_live_parity"
const PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_d2_1441_integration_live_parity"
const CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "current_integration_topology"
const ACTIVE_UNIT_BY_RECEIVER := {
	"building-composite:w1249412094:w1282547787:wall": "physical-building:w1249412094",
	"building:r16681702:wall": "physical-building:r16681702",
	"building:w1222720021:wall": "physical-building:w1222720021",
	"building:w291189336:wall": "physical-building:w291189336",
	"building:w34313540:wall": "physical-building:w34313540",
	"building:w34313545:wall": "physical-building:w34313545",
	"building:w95934105:wall": "physical-building:w95934105",
	"building:w95934119:wall": "physical-building:w95934119",
	"building:w95934144:wall": "physical-building:w95934144",
	"building:w95934117:wall": "physical-building:w95934117",
	"building:w96215646:wall": "physical-building:w96215646",
	"building:w95934125:wall": "physical-building:w95934125",
	"building:w764313741:wall": "physical-building:w764313741",
	"building:r19685981:wall": "physical-building:r19685981",
	"building:w96215661:wall": "physical-building:w96215661",
	"building:w96215653:wall": "physical-building:w96215653",
	"building:w96215651:wall": "physical-building:w96215651",
	"building:w96215649:wall": "physical-building:w96215649",
	"building:w96215652:wall": "physical-building:w96215652",
	"building:w96215658:wall": "physical-building:w96215658",
	"building:w96215677:wall": "physical-building:w96215677",
	"building:w96215680:wall": "physical-building:w96215680",
	"building:w96215672:wall": "physical-building:w96215672",
	"building:w96215669:wall": "physical-building:w96215669",
	"building:w95934123:wall": "physical-building:w95934123",
}
const ACTIVE_REVIEW_STATUS_BY_RECEIVER := {
	"building-composite:w1249412094:w1282547787:wall": "independent_exact_current_live_pass",
	"building:r16681702:wall": "pending_independent_original_detail_review",
	"building:w1222720021:wall": "pending_independent_original_detail_review",
	"building:w291189336:wall": "independent_exact_current_live_pass",
	"building:w34313540:wall": "pending_independent_original_detail_review",
	"building:w34313545:wall": "independent_exact_current_live_pass",
	"building:w95934105:wall": "independent_exact_current_live_pass",
	"building:w95934119:wall": "independent_exact_current_live_pass",
	"building:w95934144:wall": "independent_exact_current_live_pass",
	"building:w95934117:wall": "independent_exact_current_live_pass",
	"building:w96215646:wall": "independent_exact_current_live_pass",
	"building:w95934125:wall": "independent_exact_current_live_pass",
	"building:w764313741:wall": "independent_exact_current_live_pass",
	"building:r19685981:wall": "independent_exact_current_live_pass",
	"building:w96215661:wall": "independent_exact_current_live_pass",
	"building:w96215653:wall": "independent_exact_current_live_pass",
	"building:w96215651:wall": "independent_exact_current_live_pass",
	"building:w96215649:wall": "independent_exact_current_live_pass",
	"building:w96215652:wall": "independent_exact_current_live_pass",
	"building:w96215658:wall": "independent_exact_current_live_pass",
	"building:w96215677:wall": "independent_exact_current_live_pass",
	"building:w96215680:wall": "independent_exact_current_live_pass",
	"building:w96215672:wall": "independent_exact_current_live_pass",
	"building:w96215669:wall": "independent_exact_current_live_pass",
	"building:w95934123:wall": "independent_exact_current_live_pass",
}
const EXPECTED_REVIEW_RECEIPTS := {
	"physical-building:w95934144": ["cf1723b330fbd208fe92e27f5593c5f203b8f8cb99ff383ec8b389005fcc745c", "32454a02699ebce9e29e8313e70fe93894c52bd3a4ddb46c08ffeaee54891a6a", "af5f7501b08cd36629123ad14b169da764d0c375f53a6167fee80843d7a1c863", "262183b9dd5424df20527ad097bc2a07921c1f24c2ce5d359a6d7aa096052683", "bd5c009e49545f5ef84b8f0c2032c1f59dd2054d4afe0aa1f9145f74a03e2426", "56b93dc9a3e4300d6c64261618add170488002e8c305d34889d30fd55ad41af1", "f55d7a4df3fea5a1cf936d75ff0b8690b9c94f005992e5cc26da793304402119"],
	"physical-building:w95934117": ["89c301ccdf5d02b71c5f4d79eacfee55521440edfbe2c6d780cd7c1d059d72c7", "9f1101abb3e4d6ac54f27a8a6db7d72ccd098721d0f59e8a6f72a6aa4c1293ef", "b569a5dc8b72c99c873a85c4fbc49b701ba72647a0299a4f8e7b0ff06b7309bc", "327d9980de0798d7412ea691bd656f278a5e04da383c24fdb1cb272305b29e38", "6872fe9f286370de3ab11ce27124583689a7fa0c4992bb4de4f2b9e8e1073003", "b738e35d58ef6e75d0c4d98ae32d6157532703984fd48730281629211fe355a4", "7e62e914074646e438bc7c88a1f15fbc71eb40bfa00a0b04acf20e22e319c205"],
	"physical-building:w96215646": ["c7b5079a3a59847b80e201ef8107928381f9370dd74001f2675f0c68de82dbc8", "ec327adb9239a902f40fd7e2ede7afedcd19bf1869b392e9646544721eaec316", "0ad7ff068f42b8230ba724d9143c9c563130de3c9d40c37837f1ed21f95ecc60", "6a057c2b0236e90d11861499c299b723b35da37ee3590a0a154d0c3390f0b2cb", "464224831dfadcc4657fdb3575fc47501190ad41c44163a7dd05885284772689", "9be91b038dc142ac84d3947ed68733c2346aa5756e4ccbb433bf0a173b8ca364", "c2c4ee90347b458e44fda87d900a4a2031b2cf4883c16a0db1ceac0ffeec02cd"],
	"physical-building:w95934125": ["19edda17a50fd957ec09bd9a2ea310b7f82524e717c63467d5198e2e3f9500df", "4fcdd7f900dfadb12187f558bf0e545038d8386134ed1e7f9830810be763ddb5", "a1e3d98ebacaf73c5fb985a2fa2ee4597fe4c2b334cc102c3d3ea460bf361214", "088c0a0df84440cf2ddb35996aabc5d1b1aa5e1fcafe47217cd92dbbca08fc15", "18da75ad3394e86f3129449bbf113efd14d2e845acd767acba995545b3e5f6ee", "d6041941c9ec59d6a6d8fac4cbb79964fe842cdc135baf5c7a36df3a65a2c98e", "7cd3ef79e13c19bbb34b601338f86533b9de429d274d35e55e8e6f8fbd8afdce"],
	"physical-building:w764313741": ["cb06367c7de02d2379c855dfe33915d8bd54b85a33666f0582e949752f9310cf", "f68b77fa5c6e8983288ad9f9ca36a4fd827e716cc1c99877270eeceb547786b6", "4e3a0ea032384bc1381468db84ae15c4ebc1eb75212a9fec20156d165414b028", "708692fe592b56c9b18cbf5d9bbc086dadb1c053153d37afbd5c37c6a91c0a3e", "6e8e1a6d8ff3ee12e961d7adaa78cdc72e8aa57dbb607251d5a1361c171eb895", "502c87a102c90ef446a1e3415b1bb6eca7050d46689c550c18609c3c9dc43b0b", "fb4802671d8ec92d2cdff091a221fc6fe8f3d1dae6780446aa5604227f7cfed4"],
	"physical-building:r19685981": ["e08d71c45bfc67e05ab2fd2a8d4e8362ef7692f96d5817d60856a251b473b14e", "82543ad09bc51281499280965d9bc949ecc99781d80520801742bd3643404862", "83a8637cd539efa3899b8d97147a82a02d976aa8baed4209824e2724a2ac7e2b", "3c7c3e933062d4cf3994f47cb48a62c41b7c1cf42fa41693ff82474cec1db86d", "916457b92cee4b002cab5c47b6ecd29a8c8d398a9ad685c05e7bc8f5d9874e0a", "e903e64348aa003ca957b1e1efebc57a516395134f40d56e1ba1c5ebc3ad877f", "749cd826a0ea791b696ab98464e5c19548f14d45734d88111a79376a74dd5c8c"],
	"physical-building:w96215651": ["6a7813fc1a94f816bd01f55f6901a61f7d421b67e085663b6e51ad865408754e", "497ce96296ada0265a26c4d24215db320b278cff8883be00b5d637a94d2cfd64", "8205cf8904929d56d9e90842922a6be37cf64869f283c60aac666e42e571c236", "4de165e49df045101b1fd7156f0f7595c0026617db255ab3c23412b1a4424081", "3c30e9c73026a885f2ee2b3941b28e7ed6be799571c58fa733d2e209adfad7fe", "1da322cc863b923b4befee6eac8f3876c1fa0360a1848527c88cba774c935769", "669f108baf4c343f766da111c808232e6b4b611d13cf919526372e54f8642d34"],
	"physical-building:w96215653": ["8957bff439a37e22880af8b0df5c6641e348bb19e13207bd65ac8e94cb1484ad", "f240c0a442a66cdb5e20fffa4883e2b9098ce681d0fdefa3c30e846e376d517b", "c45ad15c677f1413d106695f8a1c6e339c0b6da6f4fb67eea0d9b6ae53b64018", "a28bf431f24e58cc147b3adc6df9983784f68d6f0335c61bea3bda7d02e0cfa8", "34e252f76805cd5e152fd58056f95852ba5c4ebfdc2e73ceeb20f1410c74eadb", "802e3287f84f0363a688d35454e88aebef7d34b93db88b88d16785311ec3d7d4", "45cf53232bcb34f4bf43b2370a7ce0e84ade628dc23e9aa7a8439f70eb102c03"],
	"physical-building:w96215661": ["20a5a14b31c9918f7e9e4c3884c1ca3deef55af1ccd5720c4c9d581710c42f76", "c9bdee01510d7e0c2f43be4c454b154437009583b2c59c15ba211f07ee16f259", "ac2950c05d8472b5a8edb0ce2f7b4437159d6af963145dfd142ec5bc59019b98", "0976e8393145f40ce9e07c861bdc1a032f15b0cf70e6c984244318e2adfb92d3", "4870b6e92d8d9d42c7107a27f38af1f115f39cd934e920d297363c018d3d2822", "a6ea228918898454c56fd5aebe1affbd94d0bc7c1878c966c14fc704409e028b", "ec1e740bd93a8325094811bf634d90d43c672574a002a90c96a1a454662996cf"],
	"physical-building:w96215658": ["f46366f21b1cc5ed5fb2a230fd35cdc144d02b24833292b9c1ad617f58191c55", "640768775dc2090c5742eb1b8468f0a9992086fbe06cca8ae8f5982309b20ee6", "be716635b72e105c8440c51836735e149360f20eda1fdc95b9a0bfd83f39a6e2", "47f2d83b04b14b988f9b72c22b8384120201eba933a0a9fd7ca1dd7163eda22c", "7da899b63a2f906a643ac3eeb3a92a793fa3b502e9fa60f395b58fe60139d3e0", "2e57bb89f4e646abc95a7db1a7cea82100c058121ad6755ff08edd1fd6403be2", "d45db6575672f8c713ce96ec41d577d507722a57c14417657f7c2cc564f70f81"],
	"physical-building:w96215652": ["ca45fe7f855fb98ecadecddf7a04e8b9e13f73355bed128cfc4c8ef83a13fc1c", "410d90ee3599491993fddcc0ed8accea3de05bb4e905be9076078629b36f7835", "94994da3f3db23d5bc81d4892e7ddcbafe91228aa891890198b9afee0339e961", "db006b21c253ea7dbcc937ff6ba5bf7805894f9b00b8ef6164396ee9f6b3af23", "1d2e5d2682e0b72c9c81b5962680e11c9cdba200d0ab13b11db1c6dac54f1aef", "dbef975d3b3afedac4694ea49c57f4e98e50a41f67ed2a61621dae3cc0c12176", "923517f30c75e83af49c039111fdac548d8a20c0486cdf202863e04cca41c3ef"],
	"physical-building:w96215649": ["bbc33d45ea0708df973adc24897b27ceaa052117c4f002546df64b2fdb30ef3d", "e639c2fe4ca2beebdd067a8d804d231ba4e4a9e55e4d85699496533479267de2", "e78ac76b320df4869bc882a52e5e37ad56a863f5e99734d9b45e2d84764a6424", "e094b27c9dc69797035270a9acfedcb4db9832338f4915178e101f05621b49af", "0c46621cf3d43660a7e7d8168dcdf0be5556d96b5ff1a63b0715295311565d35", "276b71133a8ae9c1f0fd8caecdbd0365f16c3ca4655d49e99149bbaec61b0ae0", "6f67a10d85551c5e4226ff47edcd15a15ce25f3a179ffa0e3670d3c0981be3fb"],
	"physical-building:w96215680": ["f58284bed7ac7fce861a282a344bac1cdb12d6b69286d0cfbde3936f9022139b", "892c34c422283ba7eadd3b5a8d005f34b8736e4b359ffc67ba7194a6c4fc110d", "98fe533ab07e2ff5f098094ad68e2b32b20712e13de75881e679eb84fb107c0f", "754b234c8806726b70400dcd759abbed3a309fad42be12669b2cf877e6e5b415", "bd06a1a34a11937410f82ad5d6903de68e8d0a1660b5a9b2d8815afeee990ea6", "4c2e64ec36a96058c8d48a7cb5f5e9c29c0e1154ff2c2db179071cc8f7553e62", "03003e86b6fb4b7fb28099876e6a788e9c8596bd14f25a794d8a1adce6fd4ecd"],
	"physical-building:w96215677": ["b3549c8b8616163a06c8fa2209562bda58ad9ce03ad3ae68751c9ca256b9e09a", "2ef58e0ef4ab39375107bf4d5354b83399eceda0bc36599b7bbb5e98bb79e6b9", "bd5aacf373d887cddf2c25ed0788ab0286faa0c9daa7cc0e9e03a81ad744bd0e", "6bee171a27e3a10b3f1927f332a678ec0826e982faa6085e71db525bcdb30096", "70f69ef17176b2810b073f4304fd17f6bc7143a70ac031d1a20922996422661c", "03f2cf746dc931dd816f28f337b12ae9f11d7cb5ef3c3087601a46bb9df427c7", "c806dc1fd6f146f8573e83b3fd8ac8523d87fba1d57e8f5e9d29a066b481f3bd"],
	"physical-building:w96215669": ["805f12798185ad8504cfac0742a27bdcb83c9da79b9aa9a192ba84081117fbab", "5eb7648cb03fa1ae73c9733c31456539d39c40a462219be43d4a92ecf7d0ce62", "fb3f03daae24bb385cbf6e86ee665a2752017ee9c5c32f54c6e21d00dbc7faf3", "35edd4f41d0cf9009aa59f66b0345992a93bb08ecd1eda8b61086b6eb5dc09db", "a2e2b8aade40eebd01d900728e65c5cabd2cb1f43465399db2ed90329d49a741", "5b6b2455b8068568e2b877b9f155982af76e4cc81f7be3341e9ec663c7c260de", "6e5961faa00944e793c213e444a96732494a6fe15e1799f06636bdd1dd7ad276"],
	"physical-building:w96215672": ["11f87bb5defc8432d5ba53e8e2eb586f631cd81db920f5fa85dc61cc34261589", "fc250debbc032d160e3de5e3e0148f13934a7e3bb17cc882a19f4d5b336fab95", "5a5de738ac8e8ed4490d4c83d63a739d5cdb9598ce66021984579dac1bf6e0c4", "c0fcacf741e513402d0b04aa35c7d5927b4205ebb80c85890a62bd2b5456c77d", "df08d70aa4307e2b7689e6c8e3ff0ad31005806b14c2420251456ddb4c60db92", "21be51860e8e35dcdf76df4753d22155cbca013f134250b365764e873b8eac86", "f449c7863040df9873f5bcd268e0eac506a9c26d6e0613881e1b294e9355bb1f"],
	"physical-building:w95934123": ["87a2af8c5ab11082337265f53ca5fcd3aa9f0dbfdd22f97e7a8968653ad71a06", "7c01ff32b1da4276ec330aee0d034dce4f0cbe8caa510f96d99504084cb314b5", "f139576c7b45eb76774315745504992f6bd726cd698faab6b88e79f491197960", "f0d21bb4dc14d8a12aba1fc37614e3cced7ff331521dda06a802bfc6fbd69dc9", "e17f311ea69445d8da9b4029e9d4d93fba19ea2cd2901efa2e2ec1d7dd90556a", "c892d30b9c06f280077712c2bbad710eefac67f9fa1dd4b1f92c8f07c0b329dc", "9c094ed7a52506404a6763298504b71706b75ade1f44e4cfe2ad3fb6ea81380f"],
	"physical-building:r16681702": ["b12858438d6522b7f3cf42fa06392648d16ee3e0c418eb5e807a3ee1be770c2a", "ebeef887b37c6845c6c8fa3f25e06706351fe7c1dab0e1a3b0eaf47dfb773017"],
	"physical-building:w1222720021": ["fb952a31151805078d1e386117ed965aa0649ffddcd17874d13493b5dd4239bb", "dbe9745f5356b2309e820c2b47987ee4463518eaf4afd77fcd37df0edc8d437a"],
	"physical-building:w1249412093": ["9e4364eaf78412c58bfcac1bad1f4f35241f48a1b373976cdfa42638ce57b680", "e1ab8f526aed22a6234fff1d2fcc5eae5d2245df4260a25a5705cd37a158a921"],
	"physical-building:w1249412094": ["37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8", "23fd6eff4ab8d9696af9d1ecc19bea50537cc824ecf3a7bebdf4fa191cd039d9"],
	"physical-building:w291189336": ["63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9", "54d434c9283a0e2d86aa836e6a21672a8756e5a170cb5724d66066e799223930"],
	"physical-building:w34313540": ["1aee23943b3df4f600b9a4e4fce86d839b75ce575a924de4ca8b187bd9120046", "4b92b71df3c7f8f7dfbb285bd7566b3f422a32be45f810d532328e15d008f5be"],
	"physical-building:w34313545": ["b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772", "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3"],
	"physical-building:w95934105": ["075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144", "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885", "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd", "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad", "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43", "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061", "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884"],
	"physical-building:w95934119": ["87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95", "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc", "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7"],
}
const BUILDING_1_RECEIVERS := ["building:r16681702:wall", "building:w1222720021:wall"]
const BUILDING_1_SOURCE_BY_RECEIVER := {
	"building:r16681702:wall": "r16681702",
	"building:w1222720021:wall": "w1222720021",
}
const BUILDING_1_PUBLIC_FRONT_CONFIG_PATH := "res://game/resources/facades/building_1_public_front_believability.json"
const BUILDING_1_PUBLIC_FRONT_CONFIG_SHA256 := "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb"
const BUILDING_1_RUNTIME_ASSETS := [
	"res://game/resources/facades/building_1_hero_model.json",
	BUILDING_1_PUBLIC_FRONT_CONFIG_PATH,
	"res://game/resources/materials/world/building_1/building_1_bluegrey_glass.tres",
	"res://game/resources/materials/world/building_1/building_1_bronze.tres",
	"res://game/resources/materials/world/building_1/building_1_canopy_underside.tres",
	"res://game/resources/materials/world/building_1/building_1_light_trim.tres",
	"res://game/resources/materials/world/building_1/building_1_projecting_base_stone.tres",
	"res://game/resources/materials/world/building_1/building_1_reveal_shadow.tres",
	"res://game/resources/materials/world/building_1/building_1_roof_metal.tres",
	"res://game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres",
	"res://game/scripts/world/facades/building_1_hero_model.gd",
]
const BUILDING_3_RECEIVER := "building:w34313540:wall"
const NAVY_CHAPEL_RECEIVER := "building:w291189336:wall"
const ISLE_HOUSE_UNIT := "physical-building:w1249412094"
const ISLE_HOUSE_HIGH_RECEIVER := "building-composite:w1249412094:w1282547786:wall"
const ISLE_HOUSE_LOW_RECEIVER := "building-composite:w1249412094:w1282547787:wall"
const ISLE_HOUSE_LIVE_REVIEW_RECEIPT_SHA256 := "37b6c7dbf6c8769b13628e1070a9c3b5beeb9b25bbe63f0f12f9aaa00c22dab8"
const ISLE_HOUSE_LIVE_SIGNATURE := "09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981"
const ISLE_HOUSE_REPAIR_SIGNATURE := "41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69"
const NAVY_CHAPEL_LIVE_REVIEW_RECEIPT_SHA256 := "63bd6c5a79db837e3b53b60eea36887cee8c4c66af791715f964f023b926b5a9"
const NAVY_CHAPEL_GEOMETRY_SIGNATURE := "076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46"
const NAVY_CHAPEL_OWNERSHIP_SIGNATURE := "4766c5d562933eb632f1ef3bdcec828fc40be81c996db919c53405f776fa04a7"
const NAVY_CHAPEL_RUNTIME_ASSETS := [
	"res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json",
	"res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_inferred_cream_structure.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_neutral_roof.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_opaque_opening.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_pale_trim.tres",
	"res://game/resources/materials/world/navy_chapel_187/standalone_hero/navy_chapel_protected_neutral.tres",
	"res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd",
	"res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd",
]
const D1_B201_RECEIVER := "building:w34313545:wall"
const D1_B201_REVIEW_RECEIPT_SHA256 := "b9ef912df2dd00fa2c456a8e7e03473001cc381cbc2dd5288e9f6ef65d8c2772"
const D1_B201_EVIDENCE_MANIFEST_SHA256 := "f169085620a0a9ff0c685e4dfa98442c5c31e4e580f1decdbd80e84b09c74fe3"
const D1_B201_DECORATIVE_SIGNATURE := "705c5345509f77cd91359f66173fff0e1e132d41ebb9acef3f51ff2c467abb3a"
const D1_B201_RUNTIME_ASSETS := [
	"res://game/resources/facades/d1_current/d1_b201_live_attachment.json",
	"res://game/resources/materials/world/d1_current/b201_green_hierarchy.tres",
	"res://game/resources/materials/world/d1_current/b201_muted_rust_post.tres",
	"res://game/resources/materials/world/d1_current/b201_service_leaf.tres",
	"res://game/resources/materials/world/d1_current/b201_warm_wall.tres",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
	"res://game/scripts/world/facades/d1_b201_live_attachment.gd",
]
const D1_B225_RECEIVER := "building:w95934119:wall"
const D1_B225_REVIEW_RECEIPT_SHA256 := "87dc2b9febf7110ccd5c1eabed1a290fea5900508561298dd7cf3b6b6fcb1d95"
const D1_B225_EVIDENCE_MANIFEST_SHA256 := "96c76fd99960f1345a7c56f7fc6678ac284f98cc601a3ba65ed57020491f18dc"
const D1_B225_EVIDENCE_TREE_SHA256 := "f42dbec489c6fda55b612aba20c99ee2233857cb60a1ce9c512d024b35d0dcb7"
const D1_B225_DECORATIVE_SIGNATURE := "02bd8542dea7aa13041728a5244ec962fa121972db17ecf55fad03b3139fe418"
const D1_B225_RUNTIME_ASSETS := [
	"res://game/resources/facades/d1_current/d1_b225_live_attachment.json",
	"res://game/resources/materials/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_v1.tres",
	"res://game/resources/materials/world/d1_current/shared_dark_glass.tres",
	"res://game/resources/materials/world/d1_current/shared_pale_frame.tres",
	"res://game/resources/textures/world/d1_b225_repair_v1/b225_aged_painted_horizontal_cladding_albedo_v1.png",
	"res://game/scripts/world/facades/d1_b225_live_attachment.gd",
]
const D2_1441_RECEIVER := "building:w95934105:wall"
const D2_1441_ADAPTER_ID := "active-adapter:d2-1441-live:building:w95934105:wall"
const D2_1441_CONFIG_SHA256 := "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111"
const D2_1441_ADAPTER_SHA256 := "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1"
const D2_1441_BUILDER_SHA256 := "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a"
const D2_1441_PROTOTYPE_SHA256 := "6c0bf201bbb38a424453f753471cb7cb8060d0323e2386a9fda3bad84acd5933"
const D2_1441_PROTOTYPE_CONFIG_SHA256 := "ebb6be74a630ad405030938dc7d27bc6fed46b2d6892a847ee653d374df57f75"
const D2_1441_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const D2_1441_GEOMETRY_SIGNATURE := "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195"
const D2_1441_OWNERSHIP_SIGNATURE := "fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d"
const D2_1441_EVIDENCE_MANIFEST_SHA256 := "3c11ba6412da6a062d89142594c7b785bf546b5c1905dc32bdd7ce7806fd6885"
const D2_1441_MOTION_TELEMETRY_MANIFEST_SHA256 := "21e2b60a8fee1bcfeb984ece6124684c15ae5b1be7fb8a813f18bc0c3b240fcd"
const D2_1441_VISUAL_MOTION_MANIFEST_SHA256 := "c885f6450d3eaac4814bde83beff1bbdccea3ae992e07a62c1e9dd8fc1259cad"
const D2_1441_EVIDENCE_TREE_SHA256 := "e52d66e479f268a9e75372da111d9c93cc1972dd1fddca9a6cb29bb6e41a4a43"
const D2_1441_PACKAGE_RECEIPT_SHA256 := "cbcda89ec1e013c3406cf919d7c7e3bcefe0df7f005be1ea0e250bfbdada1061"
const D2_1441_MECHANICAL_REVIEW_SHA256 := "c39800b1632d1e8b5e05720d02d9499e2788aaf9ef2cf0f1bb1f2b20353b7884"
const D2_1441_VISUAL_REVIEW_SHA256 := "075dfb63e4e015cdcc2201e627da5542566d21f9d1163268f790681729ae7144"
const D2_1441_RUNTIME_ASSETS := [
	"res://game/resources/facades/d2_1441_chinook_live_replacement.json",
	"res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
	"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
	"res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd",
	"res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd",
	"res://game/scripts/world/facades/site_12_housing_kit.gd",
]
const D2_1439_RECEIVER := "building:w95934144:wall"
const D2_1439_ADAPTER_ID := "active-adapter:d2-1439-live:building:w95934144:wall"
const D2_1439_CONFIG_SHA256 := "58ba0093d002a3acad06b76876b7333077bb5152827f4a59b0c9b6da132b68d9"
const D2_1439_ADAPTER_SHA256 := "d5a4458be7a5c2fb6989f9d8a343d497d2f144eb19c445de6016888e7b3cce5e"
const D2_1439_BUILDER_SHA256 := "417e4f7269292ed0c5185e85f6b5d12759cdc516ca6be069898145aaab56ab50"
const D2_1439_PROTOTYPE_SHA256 := "797dfb3075dacdf24a32b4ee0fa4959c296b35ae2d51f2d3c4dbba407fead3b7"
const D2_1439_PROTOTYPE_CONFIG_SHA256 := "1217ae0a101f0f1951a3c12303d11af3aace225745922a09aed276b1958553be"
const D2_1439_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const D2_1439_GEOMETRY_SIGNATURE := "81a05d20b03e16253675a36692c9856cf4d53509e008aacbb69bbe4eea7683e5"
const D2_1439_OWNERSHIP_SIGNATURE := "82e1fdfae492aa1942bbbb5cfb65b51d4da4c980cf85a4231c2093aaf3edc27a"
const D2_1439_EVIDENCE_MANIFEST_SHA256 := "32454a02699ebce9e29e8313e70fe93894c52bd3a4ddb46c08ffeaee54891a6a"
const D2_1439_MOTION_TELEMETRY_MANIFEST_SHA256 := "af5f7501b08cd36629123ad14b169da764d0c375f53a6167fee80843d7a1c863"
const D2_1439_VISUAL_MOTION_MANIFEST_SHA256 := "262183b9dd5424df20527ad097bc2a07921c1f24c2ce5d359a6d7aa096052683"
const D2_1439_EVIDENCE_TREE_SHA256 := "bd5c009e49545f5ef84b8f0c2032c1f59dd2054d4afe0aa1f9145f74a03e2426"
const D2_1439_PACKAGE_RECEIPT_SHA256 := "56b93dc9a3e4300d6c64261618add170488002e8c305d34889d30fd55ad41af1"
const D2_1439_MECHANICAL_REVIEW_SHA256 := "f55d7a4df3fea5a1cf936d75ff0b8690b9c94f005992e5cc26da793304402119"
const D2_1439_VISUAL_REVIEW_SHA256 := "cf1723b330fbd208fe92e27f5593c5f203b8f8cb99ff383ec8b389005fcc745c"
const D2_1439_RUNTIME_ASSETS := [
	"res://game/resources/facades/d2_1439_chinook_quality_v2_live_replacement.json",
	"res://game/resources/facades/d2_1439_chinook_quality_v2_prototype.json",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
	"res://game/resources/materials/world/site_12_housing/d2_1439_quality_v2_recess_backing.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
	"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
	"res://game/scripts/world/facades/d2_1439_chinook_quality_v2_live_replacement.gd",
	"res://game/scripts/world/facades/d2_1439_chinook_quality_v2_prototype.gd",
	"res://game/scripts/world/facades/site_12_housing_kit.gd",
]
const D2_1444_RECEIVER := "building:w95934117:wall"
const D2_1444_ADAPTER_ID := "active-adapter:d2-1444-live:building:w95934117:wall"
const D2_1444_CONFIG_SHA256 := "472f82f5a3d98b0778aca758ae8277f8b8ba9b4a39875ff54f67781280965135"
const D2_1444_ADAPTER_SHA256 := "178cc9df2c7add966a95427099b3a9900fde459e5bfc4825211e06c119cc2e32"
const D2_1444_BUILDER_SHA256 := "cbc3f6d90e5200ea81f1daaccd10442a98b0531c5c6e5358fe825bebef89fcbb"
const D2_1444_PROTOTYPE_SHA256 := "afe74e5254af720cd855fb8dbadcb71a283d0c8b2d0f79c9565dd2e62b6e9d42"
const D2_1444_PROTOTYPE_CONFIG_SHA256 := "22efb2fa24ea1db245f8fe204e3f029312da59a7a67644d2f1464f02661046ef"
const D2_1444_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const D2_1444_GEOMETRY_SIGNATURE := "1dba8f84003a0818c2ddb91504f41c3437a63fe0856ade70d1c194ca1be8d141"
const D2_1444_OWNERSHIP_SIGNATURE := "979910c4d53486b86db04cdf04528789f668a01c41dc27114e481c843b91b92d"
const D2_1444_EVIDENCE_MANIFEST_SHA256 := "9f1101abb3e4d6ac54f27a8a6db7d72ccd098721d0f59e8a6f72a6aa4c1293ef"
const D2_1444_MOTION_TELEMETRY_MANIFEST_SHA256 := "b569a5dc8b72c99c873a85c4fbc49b701ba72647a0299a4f8e7b0ff06b7309bc"
const D2_1444_VISUAL_MOTION_MANIFEST_SHA256 := "327d9980de0798d7412ea691bd656f278a5e04da383c24fdb1cb272305b29e38"
const D2_1444_EVIDENCE_TREE_SHA256 := "6872fe9f286370de3ab11ce27124583689a7fa0c4992bb4de4f2b9e8e1073003"
const D2_1444_PACKAGE_RECEIPT_SHA256 := "b738e35d58ef6e75d0c4d98ae32d6157532703984fd48730281629211fe355a4"
const D2_1444_MECHANICAL_REVIEW_SHA256 := "7e62e914074646e438bc7c88a1f15fbc71eb40bfa00a0b04acf20e22e319c205"
const D2_1444_VISUAL_REVIEW_SHA256 := "89c301ccdf5d02b71c5f4d79eacfee55521440edfbe2c6d780cd7c1d059d72c7"
const D2_1444_RUNTIME_ASSETS := [
	"res://game/resources/facades/d2_1444_croaker_quality_v2_live_replacement.json",
	"res://game/resources/facades/d2_1444_croaker_quality_v2_prototype.json",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres",
	"res://game/resources/materials/world/site_12_housing/d2_1444_quality_v2_recess_backing.tres",
	"res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg",
	"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png",
	"res://game/scripts/world/facades/d2_1444_croaker_quality_v2_live_replacement.gd",
	"res://game/scripts/world/facades/d2_1444_croaker_quality_v2_prototype.gd",
	"res://game/scripts/world/facades/site_12_housing_kit.gd",
]
const D5_1308_RECEIVER := "building:w95934123:wall"
const D5_1308_ADAPTER_ID := "active-adapter:d5-1308-live:building:w95934123:wall"
const D5_1308_CONFIG_SHA256 := "c35951faebaa921d41bf0230bf511b3a3fde9b9b1f533272030a5dfb8d8dfe8a"
const D5_1308_ADAPTER_SHA256 := "3faca37243c2ee51ff1d2834b3d581d4b7d4552a45179224371a2570b7f08ad5"
const D5_1308_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const D5_1308_PROTOTYPE_SHA256 := "6950aab112f73fdf78c1cad2f3deca72ac7e46b2a07faffe04f82987a1e07498"
const D5_1308_PROTOTYPE_CONFIG_SHA256 := "5fb9d42425df7d6f8b62ffdc3053e88ee559dc0efd0e7880b5e841ed0bf1ac8a"
const D5_1308_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const D5_1308_RUNTIME_ASSETS := ["res://game/scripts/world/facades/d5_1308_gateview_live_replacement.gd", "res://game/resources/facades/d5_1308_gateview_live_replacement.json", "res://game/scripts/world/facades/d5_1308_gateview_live_factory.gd", "res://game/resources/facades/d5_1308_gateview_live_factory.json", "res://game/resources/facades/d5_1308_siding_marks.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd", "res://game/resources/facades/d5_1308_lawn_tone.gdshader"]

const D5_1394_RECEIVER := "building:w96215646:wall"
const D5_1394_ADAPTER_ID := "active-adapter:d5-1394-live:building:w96215646:wall"
const D5_1394_CONFIG_SHA256 := "3d74e15f0a438dd4a45f2c778c415879888ef1b7a3cef75ebe7a9682db4de203"
const D5_1394_ADAPTER_SHA256 := "42e0233cdbe1be7bdcbb63603c1bb2cae4c247dde87a51f9518cc1afafc82076"
const D5_1394_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const D5_1394_PROTOTYPE_SHA256 := "25284afdd779f6b491da47218fc6fdd169dad3bb3c56da70d76680cc91781fcb"
const D5_1394_PROTOTYPE_CONFIG_SHA256 := "2f383cef8b7f141c2a4d30a5f40db45ac166fba4c52539a84a11f7e9cb3b8c86"
const D5_1394_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const D5_1394_RUNTIME_ASSETS := ["res://game/scripts/world/facades/d5_1394_gateview_live_replacement.gd", "res://game/resources/facades/d5_1394_gateview_live_replacement.json", "res://game/scripts/world/facades/d5_1394_gateview_live_factory.gd", "res://game/resources/facades/d5_1394_gateview_live_factory.json", "res://game/resources/facades/d5_1394_siding_marks.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd", "res://game/resources/facades/d5_1394_lawn_tone.gdshader"]

const D5_1317_RECEIVER := "building:w95934125:wall"
const D5_1317_ADAPTER_ID := "active-adapter:d5-1317-live:building:w95934125:wall"
const D5_1317_CONFIG_SHA256 := "d15f6ea9e14ca9723dfd3f5794718fab6ad6d0cbf24091ce0e81fd34821e554f"
const D5_1317_ADAPTER_SHA256 := "283a020492c03fde62c591ea9ebcb1e5c5403a55aca514f0998908b440d9e819"
const D5_1317_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const D5_1317_PROTOTYPE_SHA256 := "80930edee46371825bfb7b337b94bdbb4e3b7fc064aa2ba3061b6a86886af884"
const D5_1317_PROTOTYPE_CONFIG_SHA256 := "33b54fb72cf829e933a0e386e984f6ffe9d9a7c9d335ecb034e779c12bf89a26"
const D5_1317_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const D5_1317_RUNTIME_ASSETS := ["res://game/scripts/world/facades/d5_1317_gateview_live_replacement.gd", "res://game/resources/facades/d5_1317_gateview_live_replacement.json", "res://game/scripts/world/facades/d5_1317_gateview_live_factory.gd", "res://game/resources/facades/d5_1317_gateview_quality_study.json", "res://game/resources/facades/d5_1317_siding_marks.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd", "res://game/resources/facades/d5_1317_quality_study_geometry.json", "res://game/resources/facades/d5_1317_surface_tone.gdshader"]

const FIRE_STATION48_RECEIVER := "building:w764313741:wall"
const FIRE_STATION48_ADAPTER_ID := "active-adapter:fire-station48-live:building:w764313741:wall"
const FIRE_STATION48_CONFIG_SHA256 := "4b31025a80909b03b882c089bf17d50dbc6a4ee9d32fa9b072b884fd4eec061a"
const FIRE_STATION48_ADAPTER_SHA256 := "163db6f19bb7368f5aa271282c11d4028337d48cc1b2e3d37b8231e1c329d25a"
const FIRE_STATION48_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const FIRE_STATION48_PROTOTYPE_SHA256 := "33c945be3699fe7f94874d7a65ff0d01963092d0c0cb85deacaf4f794d9996d5"
const FIRE_STATION48_PROTOTYPE_CONFIG_SHA256 := "2ae853642ed360f81ea6dfe53089fa909531af8776f40462fb129076f16b6795"
const FIRE_STATION48_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const FIRE_STATION48_RUNTIME_ASSETS := ["res://game/scripts/world/facades/fire_station48_live_replacement.gd", "res://game/resources/facades/fire_station48_live_replacement.json", "res://game/scripts/world/facades/fire_station48_live_factory.gd", "res://game/resources/facades/fire_station48_quality_study.json", "res://game/resources/facades/fire_station48_upper_cladding.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd", "res://game/resources/facades/fire_station48_study_geometry.json"]

const MACEO_MAY_RECEIVER := "building:r19685981:wall"
const MACEO_MAY_ADAPTER_ID := "active-adapter:maceo-may-live:building:r19685981:wall"
const MACEO_MAY_CONFIG_SHA256 := "cf97a1197fdc2c5cea8f5befddcb6f6f75306d9a2b969a6e3297efad0b319c6c"
const MACEO_MAY_ADAPTER_SHA256 := "d9ad456c2d11437a0cf70277c7fab383359c49d6ab34ed698ec316ea97668001"
const MACEO_MAY_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const MACEO_MAY_PROTOTYPE_SHA256 := "bb47a10d3464f162516ece9ac0591bdead1791e847b89eff35fd3f59adc56c85"
const MACEO_MAY_PROTOTYPE_CONFIG_SHA256 := "11a8784bbb08ea4a6244b1da1dcc8e0c2b589ef66c55a0bd2cc8ff20ad16cd6d"
const MACEO_MAY_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const MACEO_MAY_RUNTIME_ASSETS := ["res://game/scripts/world/facades/maceo_may_live_replacement.gd", "res://game/resources/facades/maceo_may_live_replacement.json", "res://game/scripts/world/facades/maceo_may_live_factory.gd", "res://game/resources/facades/maceo_may_quality_study.json", "res://game/resources/facades/maceo_may_public_fields.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd", "res://game/resources/facades/maceo_may_study_geometry.json"]

const NORTHERN_1201_RECEIVER := "building:w96215672:wall"
const NORTHERN_1201_ADAPTER_ID := "active-adapter:northern-canopy-free-live:building:w96215672:wall"
const NORTHERN_1201_CONFIG_SHA256 := "54659ba6dde676f8a3ea122d654ff9532ffc706c6ea95b0913e4ef10fa5100b0"
const NORTHERN_1201_ADAPTER_SHA256 := "8967229a37be5401962132b846b08f1f527fb27f6aae3cd2d6d97eb70f608b82"
const NORTHERN_1201_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1201_PROTOTYPE_SHA256 := "2a01cf9fe20d81b381e445e3531377a2802082f69424445196ede570d15b2f96"
const NORTHERN_1201_PROTOTYPE_CONFIG_SHA256 := "54659ba6dde676f8a3ea122d654ff9532ffc706c6ea95b0913e4ef10fa5100b0"
const NORTHERN_1201_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1201_RUNTIME_ASSETS := ["res://game/scripts/world/facades/northern_canopy_free_live_replacement.gd", "res://game/resources/facades/northern_canopy_free_study.json", "res://game/scripts/world/facades/northern_canopy_free_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const NORTHERN_1238_RECEIVER := "building:w96215669:wall"
const NORTHERN_1238_ADAPTER_ID := "active-adapter:northpoint-1238-live:building:w96215669:wall"
const NORTHERN_1238_CONFIG_SHA256 := "a7f733e4f67351f9919769ff1329f263efbd43ca0d39a3fb30c3ac77e626c2a9"
const NORTHERN_1238_ADAPTER_SHA256 := "fef8305341da71b88c1fa90a5ccdd9bba98afc10f999de7208cc6373ff7ba9c3"
const NORTHERN_1238_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1238_PROTOTYPE_SHA256 := "2046c934f4fdaa35f12c7e343910b26a7e1cb2d7e489adc22467bcd1b41bb45f"
const NORTHERN_1238_PROTOTYPE_CONFIG_SHA256 := "a7f733e4f67351f9919769ff1329f263efbd43ca0d39a3fb30c3ac77e626c2a9"
const NORTHERN_1238_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1238_RUNTIME_ASSETS := ["res://game/scripts/world/facades/northpoint_1238_live_replacement.gd", "res://game/resources/facades/northpoint_1238_study.json", "res://game/scripts/world/facades/northpoint_1238_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const NORTHERN_1206_RECEIVER := "building:w96215677:wall"
const NORTHERN_1206_ADAPTER_ID := "active-adapter:mariner-1206-live:building:w96215677:wall"
const NORTHERN_1206_CONFIG_SHA256 := "5327998befca469042db9ac728de697e56fb311f9f889bb1bc867617425d4f97"
const NORTHERN_1206_ADAPTER_SHA256 := "88e0858a2b9d3559c8d2e766874f93cd44335f89c232e8115ef7c7f97ecc951b"
const NORTHERN_1206_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1206_PROTOTYPE_SHA256 := "906922118fd881a5668962c87964b8c46db32d92a5483fd072a4c2a90b521c56"
const NORTHERN_1206_PROTOTYPE_CONFIG_SHA256 := "5327998befca469042db9ac728de697e56fb311f9f889bb1bc867617425d4f97"
const NORTHERN_1206_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1206_RUNTIME_ASSETS := ["res://game/scripts/world/facades/mariner_1206_live_replacement.gd", "res://game/resources/facades/mariner_1206_study.json", "res://game/scripts/world/facades/mariner_1206_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const NORTHERN_1219_RECEIVER := "building:w96215680:wall"
const NORTHERN_1219_ADAPTER_ID := "active-adapter:mariner-1219-live:building:w96215680:wall"
const NORTHERN_1219_CONFIG_SHA256 := "5fd7eeb31c4d2cfac52aadff65f1bc7f35458d3e0c8d8469411f75ce032b9f21"
const NORTHERN_1219_ADAPTER_SHA256 := "c6a0c16cc762d33c62c3f3885d865999be5e65e148f56a66e9da348e6cbfb58a"
const NORTHERN_1219_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1219_PROTOTYPE_SHA256 := "216e83f6ee69313d77ef5c2007720a126e07cff5e30ce23401a1d28cdac84748"
const NORTHERN_1219_PROTOTYPE_CONFIG_SHA256 := "5fd7eeb31c4d2cfac52aadff65f1bc7f35458d3e0c8d8469411f75ce032b9f21"
const NORTHERN_1219_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1219_RUNTIME_ASSETS := ["res://game/scripts/world/facades/mariner_1219_live_replacement.gd", "res://game/resources/facades/mariner_1219_study.json", "res://game/scripts/world/facades/mariner_1219_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const NORTHERN_1212_RECEIVER := "building:w96215649:wall"
const NORTHERN_1212_ADAPTER_ID := "active-adapter:mariner-1212-live:building:w96215649:wall"
const NORTHERN_1212_CONFIG_SHA256 := "f56009b6ccb5bea7ed63911c7d940573996aad4e1c5ccaa55267adbd150b3066"
const NORTHERN_1212_ADAPTER_SHA256 := "c0941706e3cee909b260e278a07d846932b805aaeb5e12440463e43678b3513c"
const NORTHERN_1212_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1212_PROTOTYPE_SHA256 := "0594ea7a6e1f09a918349ee5af58722896e3b300ae640d8c1d4025b8219bc2a9"
const NORTHERN_1212_PROTOTYPE_CONFIG_SHA256 := "f56009b6ccb5bea7ed63911c7d940573996aad4e1c5ccaa55267adbd150b3066"
const NORTHERN_1212_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1212_RUNTIME_ASSETS := ["res://game/scripts/world/facades/mariner_1212_live_replacement.gd", "res://game/resources/facades/mariner_1212_study.json", "res://game/scripts/world/facades/mariner_1212_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const NORTHERN_1220_RECEIVER := "building:w96215652:wall"
const NORTHERN_1220_ADAPTER_ID := "active-adapter:bayside-1220-live:building:w96215652:wall"
const NORTHERN_1220_CONFIG_SHA256 := "984ebbde55fa5dcb1cea8b0d57c20e2773982bbb195e1a52b16dec250ec0735b"
const NORTHERN_1220_ADAPTER_SHA256 := "1edb75f24c3de6b4c6c780c9bb6b478225925453872e11c76f82fece8a146c38"
const NORTHERN_1220_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1220_PROTOTYPE_SHA256 := "dcfb622e4f5d2759459e17d1ab465ae9fa772167f335a2d1e0c88a111482273d"
const NORTHERN_1220_PROTOTYPE_CONFIG_SHA256 := "984ebbde55fa5dcb1cea8b0d57c20e2773982bbb195e1a52b16dec250ec0735b"
const NORTHERN_1220_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1220_RUNTIME_ASSETS := ["res://game/scripts/world/facades/bayside_1220_live_replacement.gd", "res://game/resources/facades/bayside_1220_study.json", "res://game/scripts/world/facades/bayside_1220_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const NORTHERN_1239_RECEIVER := "building:w96215658:wall"
const NORTHERN_1239_ADAPTER_ID := "active-adapter:northpoint-1239-live:building:w96215658:wall"
const NORTHERN_1239_CONFIG_SHA256 := "bf1a2073f0d371242d5636dcb47820cb6cbf47f8df9300de7aab95da3cfa6174"
const NORTHERN_1239_ADAPTER_SHA256 := "e397a0879a8beb8eca7e8ec32e80c40652cfb1b5b67a50bf6f52952f4ae44aa5"
const NORTHERN_1239_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1239_PROTOTYPE_SHA256 := "3573433b35a317f40f908c64ef05519559918f5ccca0f9af14849af2b932732d"
const NORTHERN_1239_PROTOTYPE_CONFIG_SHA256 := "bf1a2073f0d371242d5636dcb47820cb6cbf47f8df9300de7aab95da3cfa6174"
const NORTHERN_1239_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1239_RUNTIME_ASSETS := ["res://game/scripts/world/facades/northpoint_1239_live_replacement.gd", "res://game/resources/facades/northpoint_1239_study.json", "res://game/scripts/world/facades/northpoint_1239_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const NORTHERN_1222_RECEIVER := "building:w96215661:wall"
const NORTHERN_1222_ADAPTER_ID := "active-adapter:bayside-1222-live:building:w96215661:wall"
const NORTHERN_1222_CONFIG_SHA256 := "65a67decfd83b376209c8c8f80ab7f456be2006a8a907c2f36211c3e863e0ab2"
const NORTHERN_1222_ADAPTER_SHA256 := "a4f6e7242dd4130b3dca67cad165a8a3067129ab2a7455e4e0f0f76ef3c144bf"
const NORTHERN_1222_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1222_PROTOTYPE_SHA256 := "639a5ce1cce22b5635f3bccfe6cb1c7764988662b826f0c25c4183fe2ec787f9"
const NORTHERN_1222_PROTOTYPE_CONFIG_SHA256 := "65a67decfd83b376209c8c8f80ab7f456be2006a8a907c2f36211c3e863e0ab2"
const NORTHERN_1222_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1222_RUNTIME_ASSETS := ["res://game/scripts/world/facades/bayside_1222_live_replacement.gd", "res://game/resources/facades/bayside_1222_study.json", "res://game/scripts/world/facades/bayside_1222_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const NORTHERN_1227_RECEIVER := "building:w96215653:wall"
const NORTHERN_1227_ADAPTER_ID := "active-adapter:northpoint-1227-live:building:w96215653:wall"
const NORTHERN_1227_CONFIG_SHA256 := "2e8573eb855c110c0d13545d63f8fd467a25a68613d16b91cb1336462baadde7"
const NORTHERN_1227_ADAPTER_SHA256 := "ace49917dc8935c75124e70f3dc573330a2236a6a82ef948b41b1eeeee451c6e"
const NORTHERN_1227_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1227_PROTOTYPE_SHA256 := "6492b8e48226ed09c7e7171bd7fd51e25b8e347c38d87d2d0931b2b3337fb2f4"
const NORTHERN_1227_PROTOTYPE_CONFIG_SHA256 := "2e8573eb855c110c0d13545d63f8fd467a25a68613d16b91cb1336462baadde7"
const NORTHERN_1227_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1227_RUNTIME_ASSETS := ["res://game/scripts/world/facades/northpoint_1227_live_replacement.gd", "res://game/resources/facades/northpoint_1227_study.json", "res://game/scripts/world/facades/northpoint_1227_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const NORTHERN_1202_RECEIVER := "building:w96215651:wall"
const NORTHERN_1202_ADAPTER_ID := "active-adapter:mariner-1202-live:building:w96215651:wall"
const NORTHERN_1202_CONFIG_SHA256 := "8490ec8dab6302c9892b37b86542ccc18793dfe309ac7d589fb9dc9cad9ddf22"
const NORTHERN_1202_ADAPTER_SHA256 := "29f17b796ae922d967e87212f7e3ed21fa30db7d9ce4b9c2c7a2ba079e847a70"
const NORTHERN_1202_BUILDER_SHA256 := "2f592c6d4cc75f222f32fded5d0ab1591c4af250f45e311bbaf3828098f54228"
const NORTHERN_1202_PROTOTYPE_SHA256 := "c81cf174af5f91a21dc95306b77296d8d82152a54ef301e87853944b3b78c59c"
const NORTHERN_1202_PROTOTYPE_CONFIG_SHA256 := "8490ec8dab6302c9892b37b86542ccc18793dfe309ac7d589fb9dc9cad9ddf22"
const NORTHERN_1202_SITE_KIT_SHA256 := "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"
const NORTHERN_1202_RUNTIME_ASSETS := ["res://game/scripts/world/facades/mariner_1202_live_replacement.gd", "res://game/resources/facades/mariner_1202_study.json", "res://game/scripts/world/facades/mariner_1202_live_factory.gd", "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "res://game/scripts/world/facades/site_12_housing_kit.gd"]

const PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_d2_1444_integration_live_parity"
const PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE := "pre_d2_1439_integration_live_parity"

const BUILDING_3_RUNTIME_ASSETS := [
	"res://game/resources/facades/building_3_600_california_ene_layout.json",
	"res://game/resources/facades/building_3_hero_massing.json",
	"res://game/resources/materials/world/building_3/building_3_shadow_recess.tres",
	"res://game/resources/materials/world/building_3/building_3_teal_door.tres",
	"res://game/resources/materials/world/building_3/building_3_white_primary.tres",
	"res://game/scenes/world/facades/building_3/building_3_600_california_facade.tscn",
	"res://game/scenes/world/facades/building_3/building_3_ene_modules.tscn",
	"res://game/scripts/world/facades/building_3_600_california_facade.gd",
	"res://game/scripts/world/massing/building_3_600_california_massing.gd",
]
const ALLOWED_EXECUTABLE_ROOTS := [
	"res://game/scenes/world/",
	"res://game/scripts/world/",
]
const ALLOWED_EXECUTABLE_KINDS := ["gdscript", "packed_scene"]
const TEXT_ASSET_EXTENSIONS := ["gd", "gdshader", "json", "tres", "tscn"]

var _loaded := false
var _registry := {}
var _adapter_contracts := {}
var _units_by_id := {}
var _receivers_by_key := {}
var _adapters_by_id := {}
var _plans_by_receiver := {}
var _projections_by_id := {}
var _last_error_code := ""
var _last_error_message := ""

static var _measurement_enabled: bool = false
static var _measurement: Dictionary = {}


func load_default(expected_registry_sha256: String = "") -> Dictionary:
	return load_from_path(DEFAULT_REGISTRY_PATH, expected_registry_sha256)


func load_from_path(registry_path: String, expected_registry_sha256: String = "") -> Dictionary:
	_reset()
	if not _require(_is_safe_runtime_json_path(registry_path), "dirty_path", "Registry path is not an allowed game-package JSON path: %s" % registry_path):
		return _status()
	if not _require(FileAccess.file_exists(registry_path), "registry_missing", "Runtime registry is missing: %s" % registry_path):
		return _status()
	var registry_sha256 := _measured_file_sha256(registry_path)
	if not expected_registry_sha256.is_empty() and not _require(registry_sha256 == expected_registry_sha256, "registry_hash_drift", "Runtime registry hash does not match the caller's exact pin."):
		return _status()
	var registry_value: Variant = _read_json(registry_path, "registry_invalid_json")
	if _has_error():
		return _status()
	if not _require(registry_value is Dictionary, "registry_invalid_shape", "Runtime registry root must be an object."):
		return _status()
	var registry := registry_value as Dictionary
	if not _validate_registry_header(registry):
		return _status()
	var reference := registry.get("adapter_contract", {}) as Dictionary
	var contract_path := str(reference.get("path", ""))
	if not _require(contract_path == DEFAULT_ADAPTER_CONTRACT_PATH and _is_safe_runtime_json_path(contract_path), "dirty_path", "Adapter-contract path is not the exact allowed package path."):
		return _status()
	if not _require(FileAccess.file_exists(contract_path), "adapter_contract_missing", "Runtime adapter contract is missing: %s" % contract_path):
		return _status()
	var contract_sha256 := _measured_file_sha256(contract_path)
	if not _require(contract_sha256 == str(reference.get("sha256", "")), "adapter_contract_hash_drift", "Runtime adapter-contract hash drifted from the registry pin."):
		return _status()
	var contract_value: Variant = _read_json(contract_path, "adapter_contract_invalid_json")
	if _has_error():
		return _status()
	if not _require(contract_value is Dictionary, "adapter_contract_invalid_shape", "Runtime adapter-contract root must be an object."):
		return _status()
	return load_from_data(registry, contract_value as Dictionary, registry_sha256, contract_sha256)


func load_from_data(registry: Dictionary, adapter_contracts: Dictionary, registry_sha256: String = "", adapter_contract_sha256: String = "") -> Dictionary:
	_reset()
	if not _validate_registry_header(registry):
		return _status()
	if not adapter_contract_sha256.is_empty() and not _require(adapter_contract_sha256 == str((registry.get("adapter_contract", {}) as Dictionary).get("sha256", "")), "adapter_contract_hash_drift", "Runtime adapter-contract hash drifted from the registry pin."):
		return _status()
	if not _validate_registry(registry):
		return _status()
	if not _validate_adapter_contracts(adapter_contracts, registry):
		return _status()
	_registry = registry.duplicate(true)
	_adapter_contracts = adapter_contracts.duplicate(true)
	_loaded = true
	return {
		"adapter_contract_sha256": adapter_contract_sha256,
		"disabled_adapter_receivers": EXPECTED_DISABLED_ADAPTER_COUNT,
		"ok": true,
		"package_safe_adapter_receivers": EXPECTED_READY_ADAPTER_COUNT,
		"receiver_count": _receivers_by_key.size(),
		"registry_sha256": registry_sha256,
		"unit_count": _units_by_id.size(),
	}


func is_loaded() -> bool:
	return _loaded


func get_unit_count() -> int:
	return _units_by_id.size() if _loaded else 0


func get_receiver_count() -> int:
	return _receivers_by_key.size() if _loaded else 0


func get_reference_recognition_metric() -> Dictionary:
	return (_registry.get("recognition_metric", {}) as Dictionary).duplicate(true) if _loaded else {}


func get_unit(unit_id: String) -> Dictionary:
	return (_units_by_id.get(unit_id, {}) as Dictionary).duplicate(true) if _loaded else {}


func get_receiver(receiver_key: String) -> Dictionary:
	return (_receivers_by_key.get(receiver_key, {}) as Dictionary).duplicate(true) if _loaded else {}


func get_content_mode(receiver_key: String) -> String:
	return str((_receivers_by_key.get(receiver_key, {}) as Dictionary).get("runtime_content_mode", "")) if _loaded else ""


func get_adapter_plan(receiver_key: String) -> Dictionary:
	return (_plans_by_receiver.get(receiver_key, {}) as Dictionary).duplicate(true) if _loaded else {}


func get_projection_descriptor(descriptor_id: String) -> Dictionary:
	return (_projections_by_id.get(descriptor_id, {}) as Dictionary).duplicate(true) if _loaded else {}


func resolve_executable_assets(receiver_key: String) -> Dictionary:
	if not _loaded:
		return _resolution_failure("registry_not_loaded", "Load and validate the registry before resolving an adapter.")
	var plan := _plans_by_receiver.get(receiver_key, {}) as Dictionary
	if plan.is_empty():
		return _resolution_failure("adapter_plan_missing", "No adapter plan exists for receiver %s." % receiver_key)
	if str(plan.get("integration_state", "")) != "package_safe_ready_for_integration":
		return {
			"disabled_reason_code": str(plan.get("disabled_reason_code", "")),
			"error_code": "adapter_hard_disabled",
			"error_message": "Adapter has one or more pathless source projections and cannot resolve or execute.",
			"ok": false,
			"projection_descriptor_ids": (plan.get("projection_descriptor_ids", []) as Array).duplicate(),
			"receiver_key": receiver_key,
		}
	var resources := []
	for asset_value: Variant in plan.get("executable_assets", []) as Array:
		var asset := asset_value as Dictionary
		var path := str(asset.get("path", ""))
		var kind := str(asset.get("resource_kind", ""))
		if not _is_allowed_executable(path, kind):
			return _resolution_failure("dirty_path", "Executable asset is outside its allowlist: %s" % path)
		if not FileAccess.file_exists(path):
			return _resolution_failure("executable_asset_missing", "Executable asset is missing: %s" % path)
		if _measured_file_sha256(path) != str(asset.get("sha256", "")):
			return _resolution_failure("executable_asset_hash_drift", "Executable asset hash drifted: %s" % path)
		if not ResourceLoader.exists(path):
			return _resolution_failure("executable_asset_unresolvable", "Executable asset is not recognized by ResourceLoader: %s" % path)
		var resource := ResourceLoader.load(path)
		if resource == null:
			return _resolution_failure("executable_asset_load_failed", "Executable asset could not be resolved: %s" % path)
		resources.append({
			"path": path,
			"resource": resource,
			"resource_kind": kind,
		})
	return {
		"instantiated": false,
		"ok": true,
		"receiver_key": receiver_key,
		"resources": resources,
	}


func deterministic_snapshot() -> Dictionary:
	if not _loaded:
		return {}
	var unit_ids := _units_by_id.keys()
	var receiver_keys := _receivers_by_key.keys()
	var plan_receivers := _plans_by_receiver.keys()
	var projection_ids := _projections_by_id.keys()
	unit_ids.sort()
	receiver_keys.sort()
	plan_receivers.sort()
	projection_ids.sort()
	var receiver_modes := []
	for receiver_key_value: Variant in receiver_keys:
		var receiver_key := str(receiver_key_value)
		receiver_modes.append([receiver_key, get_content_mode(receiver_key)])
	return {
		"plan_receivers": plan_receivers,
		"projection_ids": projection_ids,
		"receiver_modes": receiver_modes,
		"schema_version": str(_registry.get("schema_version", "")),
		"unit_ids": unit_ids,
	}


func _validate_registry_header(registry: Dictionary) -> bool:
	if not _require(_has_exact_keys(registry, ["active_runtime_adapters", "adapter_contract", "build_contract", "claim_totals", "claim_vocabulary", "compatibility_contract", "counts", "legacy_adapters", "recognition_metric", "registry_id", "schema_version", "units"]), "unknown_registry_version", "Runtime registry contains unknown top-level fields."):
		return false
	if not _require(str(registry.get("schema_version", "")) == REGISTRY_SCHEMA_VERSION, "unknown_registry_version", "Runtime registry version is unknown or forward-incompatible."):
		return false
	var build_contract := registry.get("build_contract", {}) as Dictionary
	if not _require(_has_exact_keys(build_contract, ["authoring_catalog_sha256", "compiler_version", "generated_content_sha256", "generated_manifest_sha256", "inventory_sha256", "runtime_discovery_dependency"]), "unknown_registry_version", "Runtime registry build contract contains unknown fields."):
		return false
	if not _require(
		str(build_contract.get("compiler_version", "")) == COMPILER_VERSION
		and build_contract.get("runtime_discovery_dependency") == false
		and _is_sha256(str(build_contract.get("authoring_catalog_sha256", "")))
		and _is_sha256(str(build_contract.get("generated_content_sha256", "")))
		and _is_sha256(str(build_contract.get("generated_manifest_sha256", "")))
		and _is_sha256(str(build_contract.get("inventory_sha256", ""))),
		"unknown_registry_version",
		"Runtime registry build contract requests unsupported discovery or compiler behavior.",
	):
		return false
	var compatibility := registry.get("compatibility_contract", {}) as Dictionary
	if not _require(_has_exact_keys(compatibility, ["catalog_schema_version", "compiler_version", "forward_compatible", "loader_api_version", "unknown_version_policy"]), "unknown_registry_version", "Runtime registry compatibility fields are unknown."):
		return false
	return _require(
		str(compatibility.get("catalog_schema_version", "")) == CATALOG_SCHEMA_VERSION
		and str(compatibility.get("compiler_version", "")) == COMPILER_VERSION
		and compatibility.get("forward_compatible") == false
		and str(compatibility.get("loader_api_version", "")) == LOADER_API_VERSION
		and str(compatibility.get("unknown_version_policy", "")) == UNKNOWN_VERSION_POLICY,
		"unknown_registry_version",
		"Runtime registry compatibility contract requests an unsupported or forward version.",
	)


func _validate_registry(registry: Dictionary) -> bool:
	if not _runtime_boundary_is_clean(registry):
		return _require(false, "dirty_path", "Runtime registry contains a source-only path, URL, or absolute path.")
	var adapter_reference := registry.get("adapter_contract", {}) as Dictionary
	if not _require(_has_exact_keys(adapter_reference, ["path", "schema_version", "sha256"]), "adapter_contract_reference_invalid", "Runtime registry adapter-contract reference fields drifted."):
		return false
	if not _require(
		str(adapter_reference.get("path", "")) == DEFAULT_ADAPTER_CONTRACT_PATH
		and str(adapter_reference.get("schema_version", "")) == ADAPTER_CONTRACT_SCHEMA_VERSION
		and _is_sha256(str(adapter_reference.get("sha256", ""))),
		"adapter_contract_reference_invalid",
		"Runtime registry adapter-contract reference is invalid.",
	):
		return false
	var counts := registry.get("counts", {}) as Dictionary
	if not _require(
		int(counts.get("recognition_units", -1)) == EXPECTED_UNIT_COUNT
		and int(counts.get("direct_wall_receivers", -1)) == EXPECTED_RECEIVER_COUNT
		and int(counts.get("source_record_memberships", -1)) == EXPECTED_SOURCE_RECORD_COUNT
		and int(counts.get("runtime_adapter_receivers", -1)) == EXPECTED_ADAPTER_COUNT,
		"registry_count_drift",
		"Runtime registry canonical counts drifted.",
	):
		return false
	var legacy_adapters := registry.get("legacy_adapters", []) as Array
	var active_adapters := registry.get("active_runtime_adapters", []) as Array
	var adapters := legacy_adapters.duplicate()
	adapters.append_array(active_adapters)
	if not _require(legacy_adapters.size() == 9 and active_adapters.size() == 25 and adapters.size() == EXPECTED_ADAPTER_COUNT, "registry_count_drift", "Runtime adapter arrays do not match the expected legacy/active counts."):
		return false
	var adapter_receivers := {}
	var registry_projection_ids := {}
	for adapter_value: Variant in adapters:
		var adapter := adapter_value as Dictionary
		var adapter_id := str(adapter.get("adapter_id", ""))
		var receiver_key := str(adapter.get("receiver_key", ""))
		if not _require(not adapter_id.is_empty() and not _adapters_by_id.has(adapter_id), "duplicate_adapter", "Runtime adapter ID is missing or duplicated: %s" % adapter_id):
			return false
		if not _require(not receiver_key.is_empty() and not adapter_receivers.has(receiver_key), "adapter_receiver_missing", "Runtime adapter receiver is missing or duplicated for %s." % adapter_id):
			return false
		adapter_receivers[receiver_key] = true
		_adapters_by_id[adapter_id] = adapter
		for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
			if not _validate_runtime_asset(asset_value as Dictionary, adapter_id):
				return false
		for projection_value: Variant in adapter.get("runtime_asset_projections", []) as Array:
			var projection := projection_value as Dictionary
			if not _require(_has_exact_keys(projection, ["package_contract", "projection_id", "source_asset_sha256", "source_asset_type"]), "projection_path_forbidden", "%s projection contains an executable/source path or unknown field." % adapter_id):
				return false
			if not _require(str(projection.get("package_contract", "")) == "sanitized_adapter_metadata_summary_only" and _is_sha256(str(projection.get("source_asset_sha256", ""))), "projection_invalid", "%s projection is not a valid pathless summary." % adapter_id):
				return false
			var projection_id := str(projection.get("projection_id", ""))
			if not _require(projection_id.begins_with("runtime-projection:") and not registry_projection_ids.has(projection_id), "projection_invalid", "%s projection ID is malformed or duplicated." % adapter_id):
				return false
			registry_projection_ids[projection_id] = true
	var building_3_adapter := {}
	var isle_house_adapter := {}
	var navy_chapel_adapter := {}
	var d1_b201_adapter := {}
	var d1_b225_adapter := {}
	var d2_1441_adapter := {}
	var d2_1439_adapter := {}
	var d2_1444_adapter := {}
	var d5_1394_adapter := {}
	var d5_1317_adapter := {}
	var fire_station48_adapter := {}
	var maceo_may_adapter := {}
	var northern_1202_adapter := {}
	var northern_1227_adapter := {}
	var northern_1222_adapter := {}
	var northern_1239_adapter := {}
	var northern_1220_adapter := {}
	var northern_1212_adapter := {}
	var northern_1219_adapter := {}
	var northern_1206_adapter := {}
	var northern_1238_adapter := {}
	var northern_1201_adapter := {}
	var d5_1308_adapter := {}
	for adapter_value: Variant in active_adapters:
		var active_adapter := adapter_value as Dictionary
		if str(active_adapter.get("receiver_key", "")) == BUILDING_3_RECEIVER:
			building_3_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == ISLE_HOUSE_LOW_RECEIVER:
			isle_house_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NAVY_CHAPEL_RECEIVER:
			navy_chapel_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == D1_B201_RECEIVER:
			d1_b201_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == D1_B225_RECEIVER:
			d1_b225_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == D2_1441_RECEIVER:
			d2_1441_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == D2_1439_RECEIVER:
			d2_1439_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == D2_1444_RECEIVER:
			d2_1444_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == D5_1394_RECEIVER:
			d5_1394_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == D5_1317_RECEIVER:
			d5_1317_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == FIRE_STATION48_RECEIVER:
			fire_station48_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == MACEO_MAY_RECEIVER:
			maceo_may_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1202_RECEIVER:
			northern_1202_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1227_RECEIVER:
			northern_1227_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1222_RECEIVER:
			northern_1222_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1239_RECEIVER:
			northern_1239_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1220_RECEIVER:
			northern_1220_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1212_RECEIVER:
			northern_1212_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1219_RECEIVER:
			northern_1219_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1206_RECEIVER:
			northern_1206_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1238_RECEIVER:
			northern_1238_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == NORTHERN_1201_RECEIVER:
			northern_1201_adapter = active_adapter
		elif str(active_adapter.get("receiver_key", "")) == D5_1308_RECEIVER:
			d5_1308_adapter = active_adapter
	if not _validate_building_1_registry_adapters(active_adapters):
		return false
	if not _validate_building_3_registry_adapter(building_3_adapter):
		return false
	if not _validate_isle_house_registry_adapter(isle_house_adapter):
		return false
	if not _validate_navy_chapel_registry_adapter(navy_chapel_adapter):
		return false
	if not _validate_d1_b201_registry_adapter(d1_b201_adapter):
		return false
	if not _validate_d1_b225_registry_adapter(d1_b225_adapter):
		return false
	if not _validate_d2_1441_registry_adapter(d2_1441_adapter):
		return false
	if not _validate_d2_1439_registry_adapter(d2_1439_adapter):
		return false
	if not _validate_d2_1444_registry_adapter(d2_1444_adapter):
		return false
	if not _validate_d5_1394_registry_adapter(d5_1394_adapter):
		return false
	if not _validate_d5_1317_registry_adapter(d5_1317_adapter):
		return false
	if not _validate_fire_station48_registry_adapter(fire_station48_adapter):
		return false
	if not _validate_maceo_may_registry_adapter(maceo_may_adapter):
		return false
	if not _validate_northern_1202_registry_adapter(northern_1202_adapter):
		return false
	if not _validate_northern_1227_registry_adapter(northern_1227_adapter):
		return false
	if not _validate_northern_1222_registry_adapter(northern_1222_adapter):
		return false
	if not _validate_northern_1239_registry_adapter(northern_1239_adapter):
		return false
	if not _validate_northern_1220_registry_adapter(northern_1220_adapter):
		return false
	if not _validate_northern_1212_registry_adapter(northern_1212_adapter):
		return false
	if not _validate_northern_1219_registry_adapter(northern_1219_adapter):
		return false
	if not _validate_northern_1206_registry_adapter(northern_1206_adapter):
		return false
	if not _validate_northern_1238_registry_adapter(northern_1238_adapter):
		return false
	if not _validate_northern_1201_registry_adapter(northern_1201_adapter):
		return false
	if not _validate_d5_1308_registry_adapter(d5_1308_adapter):
		return false
	if not _validate_current_topology_authority(active_adapters):
		return false
	if not _require(registry_projection_ids.size() == EXPECTED_PROJECTION_OCCURRENCE_COUNT, "adapter_contract_count_drift", "Runtime registry projection occurrence count is not 13."):
		return false
	var units := registry.get("units", []) as Array
	if not _require(units.size() == EXPECTED_UNIT_COUNT, "registry_count_drift", "Runtime registry does not contain 213 units."):
		return false
	var source_keys := {}
	var accepted_reference_unit_ids := []
	for unit_value: Variant in units:
		var unit := unit_value as Dictionary
		var unit_id := str(unit.get("unit_id", ""))
		if not _require(not unit_id.is_empty() and not _units_by_id.has(unit_id), "duplicate_unit", "Runtime unit ID is missing or duplicated: %s" % unit_id):
			return false
		var receivers := unit.get("direct_receivers", []) as Array
		if not _require(str(unit.get("runtime_content_mode", "")) == _derive_unit_content_mode(receivers), "mixed_unit_mismatch", "%s unit summary does not match its receiver-level content modes." % unit_id):
			return false
		var claim_status := unit.get("claim_status", {}) as Dictionary
		var acceptance_records := unit.get("acceptance_records", []) as Array
		if str(claim_status.get("reference_recognizable", "")) == "accepted":
			accepted_reference_unit_ids.append(unit_id)
			if not _validate_reference_acceptance_record(unit_id, acceptance_records):
				return false
		elif not _require(acceptance_records.is_empty(), "recognition_metric_mismatch", "%s exports an acceptance receipt without an accepted physical-unit claim." % unit_id):
			return false
		_units_by_id[unit_id] = unit
		for source_value: Variant in unit.get("source_records", []) as Array:
			var source_key := str((source_value as Dictionary).get("source_key", ""))
			if not _require(not source_key.is_empty() and not source_keys.has(source_key), "duplicate_source_record", "%s has a missing or duplicate source record." % unit_id):
				return false
			source_keys[source_key] = true
		for receiver_value: Variant in receivers:
			var receiver := receiver_value as Dictionary
			var receiver_key := str(receiver.get("receiver_key", ""))
			var content_mode := str(receiver.get("runtime_content_mode", ""))
			var adapter_id_value: Variant = receiver.get("runtime_adapter_id")
			if not _require(not receiver_key.is_empty() and not _receivers_by_key.has(receiver_key), "duplicate_receiver", "%s has a missing or duplicate direct receiver." % unit_id):
				return false
			if not _require(["generated_placeholder", "legacy_adapter", "active_building_1_hero", "active_building_3_hero", "active_isle_house_variant_c", "active_navy_chapel_187_paired_replacement", "active_d1_b201_host_partition_attachment", "active_d1_b225_host_partition_attachment", "active_d2_1441_paired_replacement", "active_d2_1439_paired_replacement", "active_d2_1444_paired_replacement", "active_d5_1308_paired_replacement", "active_d5_1394_paired_replacement", "active_d5_1317_paired_replacement", "active_fire_station48_paired_replacement", "active_northern_1201_paired_replacement", "active_northern_1238_paired_replacement", "active_northern_1206_paired_replacement", "active_northern_1219_paired_replacement", "active_northern_1212_paired_replacement", "active_northern_1220_paired_replacement", "active_northern_1239_paired_replacement", "active_northern_1222_paired_replacement", "active_northern_1227_paired_replacement", "active_northern_1202_paired_replacement", "active_maceo_may_paired_replacement"].has(content_mode), "unknown_content_mode", "%s has an unknown receiver content mode." % receiver_key):
				return false
			if content_mode == "generated_placeholder":
				if not _require(adapter_id_value == null, "receiver_adapter_mismatch", "%s placeholder unexpectedly references an adapter." % receiver_key):
					return false
			else:
				var adapter_id := str(adapter_id_value)
				var adapter := _adapters_by_id.get(adapter_id, {}) as Dictionary
				if not _require(not adapter.is_empty() and str(adapter.get("receiver_key", "")) == receiver_key, "receiver_adapter_mismatch", "%s does not reference its exact adapter." % receiver_key):
					return false
			_receivers_by_key[receiver_key] = receiver
	if not _require(_units_by_id.size() == EXPECTED_UNIT_COUNT and _receivers_by_key.size() == EXPECTED_RECEIVER_COUNT and source_keys.size() == EXPECTED_SOURCE_RECORD_COUNT, "registry_count_drift", "Runtime registry unit/source/receiver partitions drifted."):
		return false
	if not _validate_active_recognition_authority(active_adapters):
		return false
	accepted_reference_unit_ids.sort()
	var expected_accepted_ids := EXPECTED_REFERENCE_RECOGNIZABLE_UNIT_IDS.duplicate()
	expected_accepted_ids.sort()
	if not _require(accepted_reference_unit_ids == expected_accepted_ids, "recognition_metric_mismatch", "Reference-recognizable physical-unit set does not match the independently accepted set."):
		return false
	if not _validate_recognition_metric(registry, accepted_reference_unit_ids):
		return false
	var isle := _units_by_id.get(ISLE_HOUSE_UNIT, {}) as Dictionary
	var isle_receivers := isle.get("direct_receivers", []) as Array
	var isle_high := _receiver_by_key(isle_receivers, ISLE_HOUSE_HIGH_RECEIVER)
	var isle_low := _receiver_by_key(isle_receivers, ISLE_HOUSE_LOW_RECEIVER)
	return _require(
		str(isle.get("runtime_content_mode", "")) == "mixed_legacy_high_and_active_variant_c_low"
		and str(isle_high.get("runtime_content_mode", "")) == "legacy_adapter"
		and str(isle_low.get("runtime_content_mode", "")) == "active_isle_house_variant_c"
		and str(isle_low.get("runtime_adapter_id", "")) == "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall"
		and not _units_by_id.has("physical-building:w1282547786")
		and not _units_by_id.has("physical-building:w1282547787"),
		"mixed_unit_mismatch",
		"Isle House high/low receiver state or one-parent numerator boundary is not truthfully represented.",
	)


func _validate_reference_acceptance_record(unit_id: String, records: Array) -> bool:
	if not _require(records.size() == 1 and EXPECTED_REVIEW_RECEIPTS.has(unit_id), "recognition_receipt_mismatch", "%s must have one allowlisted independent recognition receipt." % unit_id):
		return false
	var record := records[0] as Dictionary
	var expected := EXPECTED_REVIEW_RECEIPTS[unit_id] as Array
	if unit_id in ["physical-building:w95934105", "physical-building:w95934144", "physical-building:w95934117", "physical-building:w95934123", "physical-building:w96215646", "physical-building:w95934125", "physical-building:w764313741", "physical-building:r19685981", "physical-building:w96215672", "physical-building:w96215669", "physical-building:w96215677", "physical-building:w96215680", "physical-building:w96215649", "physical-building:w96215652", "physical-building:w96215658", "physical-building:w96215661", "physical-building:w96215653", "physical-building:w96215651"]:
		if not _require(_has_exact_keys(record, ["capture_time_recognition_metric", "evidence_manifest_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "motion_telemetry_manifest_sha256", "numerator_effect", "package_verification_receipt_sha256", "review_id", "review_kind", "review_receipt_sha256", "status", "visual_motion_manifest_sha256"]), "recognition_receipt_mismatch", "%s acceptance receipt fields drifted." % unit_id):
			return false
		if not _require(
			str(record.get("capture_time_recognition_metric", "")) == ("23/213" if unit_id == "physical-building:w96215651" else ("23/213" if unit_id == "physical-building:w96215653" else ("23/213" if unit_id == "physical-building:w96215661" else ("18/213" if unit_id == "physical-building:w96215658" else ("18/213" if unit_id == "physical-building:w96215652" else ("18/213" if unit_id == "physical-building:w96215649" else ("16/213" if unit_id == "physical-building:w96215680" else ("16/213" if unit_id == "physical-building:w96215677" else ("16/213" if unit_id == "physical-building:w96215669" else ("15/213" if unit_id == "physical-building:w96215672" else ("14/213" if unit_id in ["physical-building:w764313741", "physical-building:r19685981"] else ("13/213" if unit_id in ["physical-building:w95934123", "physical-building:w96215646", "physical-building:w95934125"] else ("8/213" if unit_id == "physical-building:w95934105" else "9/213")))))))))))))
			and str(record.get("review_id", "")) == ("northern-1202-quality-candidate-2026-09-14-001" if unit_id == "physical-building:w96215651" else ("northern-1227-quality-candidate-2026-09-14-001" if unit_id == "physical-building:w96215653" else ("northern-1222-quality-candidate-2026-09-14-001" if unit_id == "physical-building:w96215661" else ("northern-1239-quality-candidate-2026-09-14-001" if unit_id == "physical-building:w96215658" else ("northern-1220-quality-candidate-2026-09-14-001" if unit_id == "physical-building:w96215652" else ("northern-1212-quality-candidate-2026-09-14-001" if unit_id == "physical-building:w96215649" else ("northern-1219-quality-candidate-2026-09-13-001" if unit_id == "physical-building:w96215680" else ("northern-1206-quality-candidate-2026-09-13-001" if unit_id == "physical-building:w96215677" else ("northern-1238-quality-candidate-2026-09-13-001" if unit_id == "physical-building:w96215669" else ("northern-1201-quality-candidate-2026-09-13-001" if unit_id == "physical-building:w96215672" else ("maceo-may-quality-candidate-2026-09-11-001" if unit_id == "physical-building:r19685981" else ("fire-station48-quality-candidate-2026-09-11-001" if unit_id == "physical-building:w764313741" else ("d5-1317-quality-candidate-2026-09-10-001" if unit_id == "physical-building:w95934125" else ("d5-1394-fidelity-quality-candidate-2026-09-10-001" if unit_id == "physical-building:w96215646" else ("d5-1308-fidelity-quality-candidate-2026-09-10-001" if unit_id == "physical-building:w95934123" else ("d2-1444-quality-v2-promotion-candidate-2026-09-09-001" if unit_id == "physical-building:w95934117" else ("d2-1439-quality-v2-promotion-candidate-2026-09-09-001" if unit_id == "physical-building:w95934144" else "d2-1441-production-v8-staging-2026-09-05-009")))))))))))))))))
			and str(record.get("review_receipt_sha256", "")) == str(expected[0])
			and str(record.get("evidence_manifest_sha256", "")) == str(expected[1])
			and str(record.get("motion_telemetry_manifest_sha256", "")) == str(expected[2])
			and str(record.get("visual_motion_manifest_sha256", "")) == str(expected[3])
			and str(record.get("evidence_tree_sha256", "")) == str(expected[4])
			and str(record.get("package_verification_receipt_sha256", "")) == str(expected[5])
			and str(record.get("mechanical_review_receipt_sha256", "")) == str(expected[6])
			and int(record.get("numerator_effect", -1)) == (0 if unit_id in ["physical-building:w95934123", "physical-building:w96215646"] else 1)
			and [
				record.get("review_receipt_sha256", ""),
				record.get("evidence_manifest_sha256", ""),
				record.get("motion_telemetry_manifest_sha256", ""),
				record.get("visual_motion_manifest_sha256", ""),
				record.get("evidence_tree_sha256", ""),
				record.get("package_verification_receipt_sha256", ""),
				record.get("mechanical_review_receipt_sha256", ""),
			].all(func(value: Variant) -> bool: return _is_sha256(str(value))),
			"recognition_receipt_mismatch",
			"%s frozen static/telemetry/visual/package/review/tree receipts, capture-time metric, or one-unit effect drifted." % unit_id,
		):
			return false
	elif unit_id == "physical-building:w95934119":
		if not _require(_has_exact_keys(record, ["capture_time_recognition_metric", "evidence_manifest_sha256", "evidence_tree_sha256", "numerator_effect", "review_id", "review_kind", "review_receipt_sha256", "status"]), "recognition_receipt_mismatch", "%s acceptance receipt fields drifted." % unit_id):
			return false
		if not _require(
			str(record.get("capture_time_recognition_metric", "")) == "7/213"
			and str(record.get("evidence_tree_sha256", "")) == str(expected[2])
			and int(record.get("numerator_effect", -1)) == 1
			and str(record.get("review_id", "")) == "d1-b225-production-attachment-v7-staging-2026-09-05"
			and _is_sha256(str(record.get("evidence_tree_sha256", ""))),
			"recognition_receipt_mismatch",
			"%s frozen capture-time metric, evidence tree, or numerator effect drifted." % unit_id,
		):
			return false
	elif not _require(_has_exact_keys(record, ["evidence_manifest_sha256", "review_id", "review_kind", "review_receipt_sha256", "status"]), "recognition_receipt_mismatch", "%s acceptance receipt fields drifted." % unit_id):
		return false
	return _require(
		str(record.get("review_kind", "")) == "independent_reference_recognition"
		and str(record.get("status", "")) == "accept"
		and str(record.get("review_receipt_sha256", "")) == str(expected[0])
		and str(record.get("evidence_manifest_sha256", "")) == str(expected[1])
		and _is_sha256(str(record.get("review_receipt_sha256", "")))
		and _is_sha256(str(record.get("evidence_manifest_sha256", ""))),
		"recognition_receipt_mismatch",
		"%s independent review or evidence receipt pin drifted." % unit_id,
	)


func _validate_active_recognition_authority(active_adapters: Array) -> bool:
	var expected_keys := [
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
	]
	for adapter_value: Variant in active_adapters:
		var adapter := adapter_value as Dictionary
		var adapter_id := str(adapter.get("adapter_id", ""))
		var receiver_key := str(adapter.get("receiver_key", ""))
		if not _require(_has_exact_keys(adapter, expected_keys), "recognition_authority_mismatch", "%s active adapter recognition-authority fields drifted." % adapter_id):
			return false
		if not _require(ACTIVE_UNIT_BY_RECEIVER.has(receiver_key), "recognition_authority_mismatch", "%s has no exact receiver-to-physical-unit authority mapping." % adapter_id):
			return false
		var unit_id := str(ACTIVE_UNIT_BY_RECEIVER[receiver_key])
		var unit := _units_by_id.get(unit_id, {}) as Dictionary
		var receiver := _receiver_by_key(unit.get("direct_receivers", []) as Array, receiver_key)
		var claim_status := unit.get("claim_status", {}) as Dictionary
		var recognition_status := str(adapter.get("recognition_acceptance_status", ""))
		if not _require(
			not unit.is_empty()
			and not receiver.is_empty()
			and str(adapter.get("review_status", "")) == str(ACTIVE_REVIEW_STATUS_BY_RECEIVER.get(receiver_key, ""))
			and str(adapter.get("review_status_scope", "")) == ACTIVE_REVIEW_STATUS_SCOPE
			and str(adapter.get("recognition_acceptance_authority", "")) == ACTIVE_RECOGNITION_ACCEPTANCE_AUTHORITY
			and recognition_status == "accepted"
			and recognition_status == str(claim_status.get("reference_recognizable", "")),
			"recognition_authority_mismatch",
			"%s does not derive recognizability from its accepted physical-unit claim." % adapter_id,
		):
			return false
		if not _validate_reference_acceptance_record(unit_id, unit.get("acceptance_records", []) as Array):
			return false
	return true


func _validate_recognition_metric(registry: Dictionary, accepted_unit_ids: Array) -> bool:
	var metric := registry.get("recognition_metric", {}) as Dictionary
	if not _require(_has_exact_keys(metric, ["accepted_physical_unit_ids", "denominator", "denominator_kind", "display", "isle_house_non_numerator_source_keys", "numerator", "rollup_policy"]), "recognition_metric_mismatch", "Runtime recognition metric fields drifted."):
		return false
	var metric_ids := (metric.get("accepted_physical_unit_ids", []) as Array).duplicate()
	metric_ids.sort()
	var claim_totals := registry.get("claim_totals", {}) as Dictionary
	var reference_totals := claim_totals.get("reference_recognizable", {}) as Dictionary
	var game_totals := claim_totals.get("game_distinctive", {}) as Dictionary
	var fidelity_totals := claim_totals.get("as_built_fidelity", {}) as Dictionary
	var receiver_totals := claim_totals.get("receiver_complete", {}) as Dictionary
	return _require(
		metric_ids == accepted_unit_ids
		and int(metric.get("numerator", -1)) == EXPECTED_REFERENCE_RECOGNIZABLE_COUNT
		and int(metric.get("denominator", -1)) == EXPECTED_UNIT_COUNT
		and str(metric.get("display", "")) == "%d/%d" % [EXPECTED_REFERENCE_RECOGNIZABLE_COUNT, EXPECTED_UNIT_COUNT]
		and str(metric.get("denominator_kind", "")) == "immutable_physical_recognition_units"
		and str(metric.get("rollup_policy", "")) == "one_claim_per_physical_recognition_unit"
		and metric.get("isle_house_non_numerator_source_keys", []) == ["w1282547786", "w1282547787"]
		and int(reference_totals.get("accepted", -1)) == EXPECTED_REFERENCE_RECOGNIZABLE_COUNT
		and int(reference_totals.get("not_evaluated", -1)) == EXPECTED_UNIT_COUNT - EXPECTED_REFERENCE_RECOGNIZABLE_COUNT
		and int(reference_totals.get("blocked", -1)) == 0
		and int(reference_totals.get("rejected", -1)) == 0
		and int(game_totals.get("accepted", -1)) == 0
		and int(fidelity_totals.get("claimed", -1)) == 0
		and int(fidelity_totals.get("limited", -1)) == 0
		and int(receiver_totals.get("verified", -1)) == EXPECTED_UNIT_COUNT,
		"recognition_metric_mismatch",
		"Runtime physical-entity recognition rollup does not match the accepted-unit list with claim dimensions separated.",
	)


func _validate_adapter_contracts(contracts: Dictionary, registry: Dictionary) -> bool:
	if not _runtime_boundary_is_clean(contracts):
		return _require(false, "dirty_path", "Runtime adapter contracts contain a source-only path, URL, or absolute path.")
	if not _require(_has_exact_keys(contracts, ["build_contract", "contract_id", "counts", "loader_contract", "plans", "projection_descriptors", "schema_version"]), "unknown_adapter_contract_version", "Runtime adapter contracts contain unknown top-level fields."):
		return false
	if not _require(str(contracts.get("schema_version", "")) == ADAPTER_CONTRACT_SCHEMA_VERSION, "unknown_adapter_contract_version", "Runtime adapter-contract version is unknown or forward-incompatible."):
		return false
	if not _require(str(contracts.get("contract_id", "")) == "treasure-island-facade-runtime-adapters", "unknown_adapter_contract_version", "Runtime adapter-contract identity is unknown."):
		return false
	var build_contract := contracts.get("build_contract", {}) as Dictionary
	var registry_build := registry.get("build_contract", {}) as Dictionary
	if not _require(_has_exact_keys(build_contract, ["authoring_catalog_sha256", "compiler_version", "runtime_registry_schema_version", "unknown_version_policy"]), "unknown_adapter_contract_version", "Runtime adapter build contract contains unknown fields."):
		return false
	if not _require(
		str(build_contract.get("compiler_version", "")) == COMPILER_VERSION
		and str(build_contract.get("runtime_registry_schema_version", "")) == REGISTRY_SCHEMA_VERSION
		and str(build_contract.get("unknown_version_policy", "")) == UNKNOWN_VERSION_POLICY
		and str(build_contract.get("authoring_catalog_sha256", "")) == str(registry_build.get("authoring_catalog_sha256", "")),
		"unknown_adapter_contract_version",
		"Runtime adapter build contract requests an unsupported or forward version.",
	):
		return false
	var loader_contract := contracts.get("loader_contract", {}) as Dictionary
	if not _require(_has_exact_keys(loader_contract, ["allowed_executable_kinds", "allowed_executable_roots", "api_version", "instantiation_authorized", "loader_path", "loader_sha256", "projection_execution_policy", "unknown_version_policy"]), "unknown_loader_version", "Runtime loader contract contains unknown fields."):
		return false
	if not _require(
		str(loader_contract.get("api_version", "")) == LOADER_API_VERSION
		and loader_contract.get("allowed_executable_kinds", []) == ALLOWED_EXECUTABLE_KINDS
		and loader_contract.get("allowed_executable_roots", []) == ALLOWED_EXECUTABLE_ROOTS
		and loader_contract.get("instantiation_authorized") == false
		and str(loader_contract.get("loader_path", "")) == DEFAULT_LOADER_PATH
		and _is_sha256(str(loader_contract.get("loader_sha256", "")))
		and FileAccess.file_exists(DEFAULT_LOADER_PATH)
		and _measured_file_sha256(DEFAULT_LOADER_PATH) == str(loader_contract.get("loader_sha256", ""))
		and str(loader_contract.get("projection_execution_policy", "")) == "forbidden"
		and str(loader_contract.get("unknown_version_policy", "")) == UNKNOWN_VERSION_POLICY,
		"unknown_loader_version",
		"Runtime loader contract requests unsupported execution or forward compatibility.",
	):
		return false
	var counts := contracts.get("counts", {}) as Dictionary
	if not _require(_has_exact_keys(counts, ["disabled_adapter_receivers", "disabled_projection_occurrences", "disabled_unique_projection_inputs", "package_safe_adapter_receivers", "receiver_adapter_plans"]), "adapter_contract_count_drift", "Runtime adapter counts contain unknown fields."):
		return false
	if not _require(
		int(counts.get("receiver_adapter_plans", -1)) == EXPECTED_ADAPTER_COUNT
		and int(counts.get("package_safe_adapter_receivers", -1)) == EXPECTED_READY_ADAPTER_COUNT
		and int(counts.get("disabled_adapter_receivers", -1)) == EXPECTED_DISABLED_ADAPTER_COUNT
		and int(counts.get("disabled_unique_projection_inputs", -1)) == EXPECTED_PROJECTION_DESCRIPTOR_COUNT
		and int(counts.get("disabled_projection_occurrences", -1)) == EXPECTED_PROJECTION_OCCURRENCE_COUNT,
		"adapter_contract_count_drift",
		"Runtime adapter contract counts drifted.",
	):
		return false
	var descriptors := contracts.get("projection_descriptors", []) as Array
	if not _require(descriptors.size() == EXPECTED_PROJECTION_DESCRIPTOR_COUNT, "adapter_contract_count_drift", "Runtime adapter contract does not contain 13 projection descriptors."):
		return false
	var projection_occurrence_count := 0
	var projection_occurrences := {}
	for descriptor_value: Variant in descriptors:
		var descriptor := descriptor_value as Dictionary
		var descriptor_id := str(descriptor.get("descriptor_id", ""))
		if not _require(_has_exact_keys(descriptor, ["consumer_adapter_ids", "descriptor_id", "disabled_reason_code", "execution_policy", "execution_state", "occurrence_projection_ids", "source_asset_sha256", "source_asset_type"]), "projection_path_forbidden", "%s projection descriptor contains a path or unknown field." % descriptor_id):
			return false
		if not _require(
			descriptor_id.begins_with("disabled-projection-input:")
			and _is_sha256(descriptor_id.trim_prefix("disabled-projection-input:"))
			and not _projections_by_id.has(descriptor_id)
			and str(descriptor.get("execution_state", "")) == "hard_disabled"
			and str(descriptor.get("execution_policy", "")) == "never_resolve_or_execute"
			and str(descriptor.get("disabled_reason_code", "")) == "source_bearing_dependency_closure_requires_independent_package_safe_normalization"
			and _is_sha256(str(descriptor.get("source_asset_sha256", "")))
			and ["gd", "json"].has(str(descriptor.get("source_asset_type", ""))),
			"projection_invalid",
			"%s projection descriptor is not pathless and hard-disabled." % descriptor_id,
		):
			return false
		var occurrences := descriptor.get("occurrence_projection_ids", []) as Array
		var consumers := descriptor.get("consumer_adapter_ids", []) as Array
		if not _require(not consumers.is_empty() and _array_is_unique(consumers), "projection_invalid", "%s projection consumers are missing or duplicated." % descriptor_id):
			return false
		if not _require(not occurrences.is_empty() and _array_is_unique(occurrences), "projection_invalid", "%s projection occurrences are missing or duplicated." % descriptor_id):
			return false
		for occurrence_value: Variant in occurrences:
			var occurrence_id := str(occurrence_value)
			if not _require(occurrence_id.begins_with("runtime-projection:") and not projection_occurrences.has(occurrence_id), "projection_invalid", "%s projection occurrence is malformed or duplicated." % descriptor_id):
				return false
			projection_occurrences[occurrence_id] = descriptor_id
		projection_occurrence_count += occurrences.size()
		_projections_by_id[descriptor_id] = descriptor
	if not _require(projection_occurrence_count == EXPECTED_PROJECTION_OCCURRENCE_COUNT, "adapter_contract_count_drift", "Runtime projection occurrence count drifted."):
		return false
	var plans := contracts.get("plans", []) as Array
	if not _require(plans.size() == EXPECTED_ADAPTER_COUNT, "adapter_contract_count_drift", "Runtime adapter contract does not contain %d plans." % EXPECTED_ADAPTER_COUNT):
		return false
	var ready_count := 0
	var disabled_count := 0
	for plan_value: Variant in plans:
		var plan := plan_value as Dictionary
		var adapter_id := str(plan.get("adapter_id", ""))
		var receiver_key := str(plan.get("receiver_key", ""))
		if not _require(_has_exact_keys(plan, ["adapter_id", "behavior_contract", "content_mode", "disabled_reason_code", "executable_assets", "integration_state", "projection_descriptor_ids", "receiver_key", "resolution_policy", "runtime_assets", "source_key"]), "adapter_plan_mismatch", "%s contains unknown adapter-plan fields." % adapter_id):
			return false
		var adapter := _adapters_by_id.get(adapter_id, {}) as Dictionary
		if not _require(not adapter.is_empty() and str(adapter.get("receiver_key", "")) == receiver_key and str(adapter.get("source_key", "")) == str(plan.get("source_key", "")) and not _plans_by_receiver.has(receiver_key), "adapter_plan_mismatch", "%s does not match one exact runtime adapter receiver/source." % adapter_id):
			return false
		var receiver := _receivers_by_key.get(receiver_key, {}) as Dictionary
		if not _require(not receiver.is_empty() and str(receiver.get("runtime_content_mode", "")) == str(plan.get("content_mode", "")), "adapter_plan_mismatch", "%s content mode does not match its exact receiver." % adapter_id):
			return false
		if not _require(_runtime_asset_arrays_match(adapter.get("runtime_assets", []) as Array, plan.get("runtime_assets", []) as Array), "adapter_plan_mismatch", "%s runtime assets drifted from the registry." % adapter_id):
			return false
		if str(plan.get("content_mode", "")) == "active_building_1_hero":
			if not _validate_building_1_plan(plan, adapter):
				return false
		elif str(plan.get("content_mode", "")) == "active_building_3_hero":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_building_3_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_isle_house_variant_c":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_isle_house_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s Isle House behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_navy_chapel_187_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_navy_chapel_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s Navy Chapel behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_d1_b201_host_partition_attachment":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_d1_b201_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s D1 B201 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_d1_b225_host_partition_attachment":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_d1_b225_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s D1 B225 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_d2_1441_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_d2_1441_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_d2_1441_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s D2 1441 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_d2_1439_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_d2_1439_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_d2_1439_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s D2 1439 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_d2_1444_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_d2_1444_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_d2_1444_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s D2 1444 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_d5_1394_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_d5_1394_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_d5_1394_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s D5 1394 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_d5_1317_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_d5_1317_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_d5_1317_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s D5 1317 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_fire_station48_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_fire_station48_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_fire_station48_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s Station48 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_maceo_may_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_maceo_may_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_maceo_may_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s Maceo May behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1202_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1202_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1202_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1202 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1227_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1227_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1227_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1227 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1222_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1222_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1222_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1222 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1239_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1239_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1239_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1239 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1220_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1220_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1220_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1220 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1212_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1212_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1212_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1212 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1219_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1219_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1219_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1219 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1206_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1206_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1206_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1206 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1238_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1238_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1238_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1238 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_northern_1201_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_northern_1201_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_northern_1201_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s 1201 behavior contract drifted from the registry." % adapter_id):
				return false
		elif str(plan.get("content_mode", "")) == "active_d5_1308_paired_replacement":
			var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
			if not _validate_d5_1308_behavior_contract(plan.get("behavior_contract", {}) as Dictionary) \
			or not _validate_d5_1308_plan_contract(plan) \
			or not _require(JSON.stringify(plan.get("behavior_contract", {})) == JSON.stringify(runtime_contract.get("behavior_contract", {})), "adapter_plan_mismatch", "%s D5 1308 behavior contract drifted from the registry." % adapter_id):
				return false
		elif not _require(plan.get("behavior_contract") == null, "adapter_plan_mismatch", "%s unexpectedly exports a target-specific behavior contract." % adapter_id):
			return false
		var projection_ids := plan.get("projection_descriptor_ids", []) as Array
		if not _require(projection_ids.all(func(id: Variant) -> bool: return _projections_by_id.has(str(id))), "projection_invalid", "%s references an unknown disabled projection." % adapter_id):
			return false
		var expected_projection_ids := _projection_descriptor_ids_for_adapter(adapter)
		var actual_projection_ids := projection_ids.duplicate()
		expected_projection_ids.sort()
		actual_projection_ids.sort()
		if not _require(actual_projection_ids == expected_projection_ids, "projection_invalid", "%s pathless projection membership drifted from the registry." % adapter_id):
			return false
		var hard_disabled := not projection_ids.is_empty()
		if hard_disabled:
			disabled_count += 1
			if not _require(
				str(plan.get("integration_state", "")) == "hard_disabled_source_projection"
				and str(plan.get("resolution_policy", "")) == "deny_all_executable_resolution"
				and str(plan.get("disabled_reason_code", "")) == "one_or_more_source_bearing_projection_inputs_have_no_parity_proven_package_safe_executable"
				and (plan.get("executable_assets", []) as Array).is_empty(),
				"disabled_adapter_exposes_executable",
				"%s must remain hard-disabled with no executable asset." % adapter_id,
			):
				return false
		else:
			ready_count += 1
			if not _require(str(plan.get("integration_state", "")) == "package_safe_ready_for_integration" and str(plan.get("resolution_policy", "")) == "resolve_only_without_instantiation" and plan.get("disabled_reason_code") == null, "adapter_plan_mismatch", "%s package-safe plan state drifted." % adapter_id):
				return false
		for asset_value: Variant in plan.get("runtime_assets", []) as Array:
			if not _validate_runtime_asset(asset_value as Dictionary, adapter_id):
				return false
		for asset_value: Variant in plan.get("executable_assets", []) as Array:
			var asset := asset_value as Dictionary
			var path := str(asset.get("path", ""))
			var kind := str(asset.get("resource_kind", ""))
			if not _require(_has_exact_keys(asset, ["path", "resource_kind", "sha256"]), "adapter_plan_mismatch", "%s executable asset fields drifted." % adapter_id):
				return false
			if not _require(_is_allowed_executable(path, kind), "dirty_path", "%s executable asset is outside the loader allowlist." % adapter_id):
				return false
			if not _require(_runtime_asset_match(plan.get("runtime_assets", []) as Array, path, str(asset.get("sha256", ""))), "adapter_plan_mismatch", "%s executable asset is not an exact runtime-asset subset." % adapter_id):
				return false
		_plans_by_receiver[receiver_key] = plan
	if not _require(ready_count == EXPECTED_READY_ADAPTER_COUNT and disabled_count == EXPECTED_DISABLED_ADAPTER_COUNT and _plans_by_receiver.size() == EXPECTED_ADAPTER_COUNT, "adapter_contract_count_drift", "Runtime adapter ready/disabled plan partition drifted."):
		return false
	for descriptor_value: Variant in descriptors:
		var descriptor := descriptor_value as Dictionary
		var descriptor_id := str(descriptor.get("descriptor_id", ""))
		for consumer_value: Variant in descriptor.get("consumer_adapter_ids", []) as Array:
			var consumer_id := str(consumer_value)
			var consumer := _adapters_by_id.get(consumer_id, {}) as Dictionary
			var consumer_plan := _plans_by_receiver.get(str(consumer.get("receiver_key", "")), {}) as Dictionary
			if not _require(not consumer.is_empty() and (consumer_plan.get("projection_descriptor_ids", []) as Array).has(descriptor_id), "projection_invalid", "%s consumer does not reference its projection descriptor." % consumer_id):
				return false
		for occurrence_value: Variant in descriptor.get("occurrence_projection_ids", []) as Array:
			if not _require(_registry_projection_occurrence_matches(str(occurrence_value), descriptor), "projection_invalid", "%s occurrence does not match any registry projection." % str(occurrence_value)):
				return false
	return true


func _validate_building_1_registry_adapters(active_adapters: Array) -> bool:
	var seen := {}
	for adapter_value: Variant in active_adapters:
		var adapter := adapter_value as Dictionary
		var receiver_key := str(adapter.get("receiver_key", ""))
		if not BUILDING_1_RECEIVERS.has(receiver_key):
			continue
		if not _require(not seen.has(receiver_key), "building_1_closure_mismatch", "Building 1/tower active adapter is duplicated for %s." % receiver_key):
			return false
		seen[receiver_key] = true
		var assets := adapter.get("runtime_assets", []) as Array
		var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
		var actual_paths := []
		for asset_value: Variant in assets:
			actual_paths.append(str((asset_value as Dictionary).get("path", "")))
		actual_paths.sort()
		var expected_paths := BUILDING_1_RUNTIME_ASSETS.duplicate()
		expected_paths.sort()
		if not _require(
			str(adapter.get("adapter_id", "")) == "active-adapter:building-1-hero:%s" % receiver_key
			and str(adapter.get("source_key", "")) == str(BUILDING_1_SOURCE_BY_RECEIVER.get(receiver_key, ""))
			and str(adapter.get("attachment_kind", "")) == "active_building_1_hero_replacement"
			and str(adapter.get("content_classification", "")) == "active_target_specific_hero_replacement"
			and str(adapter.get("runtime_content_mode", "")) == "active_building_1_hero"
			and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
			and (adapter.get("runtime_asset_projections", []) as Array).is_empty()
			and assets.size() == 11
			and actual_paths == expected_paths,
			"building_1_closure_mismatch",
			"%s does not expose the exact active Building 1 hero classification and 11-asset closure." % receiver_key,
		):
			return false
		if not _require(_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "public_front_config_sha256"]), "building_1_closure_mismatch", "%s active runtime contract fields drifted." % receiver_key):
			return false
		if not _require(
			str(runtime_contract.get("public_front_config_sha256", "")) == BUILDING_1_PUBLIC_FRONT_CONFIG_SHA256
			and _runtime_asset_match(assets, BUILDING_1_PUBLIC_FRONT_CONFIG_PATH, BUILDING_1_PUBLIC_FRONT_CONFIG_SHA256)
			and runtime_contract.get("behavior_contract") == null,
			"building_1_closure_mismatch",
			"%s omits or substitutes the exact public-front config/hash contract." % receiver_key,
		):
			return false
	return _require(seen.size() == BUILDING_1_RECEIVERS.size(), "building_1_closure_mismatch", "Building 1 and tower must each expose one exact active 11-asset adapter.")


func _validate_building_1_plan(plan: Dictionary, adapter: Dictionary) -> bool:
	var receiver_key := str(plan.get("receiver_key", ""))
	var assets := plan.get("runtime_assets", []) as Array
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	return _require(
		BUILDING_1_RECEIVERS.has(receiver_key)
		and assets.size() == 11
		and (plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and plan.get("behavior_contract") == null
		and str(runtime_contract.get("public_front_config_sha256", "")) == BUILDING_1_PUBLIC_FRONT_CONFIG_SHA256
		and _runtime_asset_match(assets, BUILDING_1_PUBLIC_FRONT_CONFIG_PATH, BUILDING_1_PUBLIC_FRONT_CONFIG_SHA256),
		"building_1_closure_mismatch",
		"%s adapter plan omits or substitutes the exact 11-asset Building 1 public-front closure." % receiver_key,
	)


func _validate_building_3_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "building_3_parity_mismatch", "Building 3 active wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == "active-adapter:building-3-hero:building:w34313540:wall"
		and str(adapter.get("source_key", "")) == "w34313540"
		and str(adapter.get("attachment_kind", "")) == "active_building_3_wall_roof_hero_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_hero_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_building_3_hero"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"building_3_parity_mismatch",
		"Building 3 active adapter classification or source ownership drifted.",
	):
		return false
	var actual_paths := []
	for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := BUILDING_3_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "building_3_parity_mismatch", "Building 3 active adapter does not contain its exact wrapper/config/facade asset set."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256"]), "building_3_parity_mismatch", "Building 3 active runtime contract fields drifted."):
		return false
	if not _require(
		_runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/massing/building_3_600_california_massing.gd", str(runtime_contract.get("adapter_sha256", "")))
		and _runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/resources/facades/building_3_hero_massing.json", str(runtime_contract.get("config_sha256", "")))
		and _is_sha256(str(runtime_contract.get("dispatch_sha256", ""))),
		"building_3_parity_mismatch",
		"Building 3 wrapper/config hashes or compiler-verified dispatch identity do not bind exact-current runtime behavior.",
	):
		return false
	return _validate_building_3_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_building_3_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["collision_contract", "facade_contract", "geometry_contract", "parity_status", "replacement_contract", "schema_version"]), "building_3_parity_mismatch", "Building 3 behavior parity fields drifted."):
		return false
	var collision := contract.get("collision_contract", {}) as Dictionary
	var facade := contract.get("facade_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(collision, ["collision_matches_visible_geometry", "roof_landing_world_solid", "spray_ownership", "wall_world_solid"])
		and _has_exact_keys(facade, ["collision_owner", "deterministic_signature", "render_only", "runtime_bound_to_wall_massing"])
		and _has_exact_keys(geometry, ["generated_bytes_unchanged", "horizontal_source_footprint_preserved", "profile_signature", "roof_geometry_signature", "roof_triangles", "topology_delta_triangles", "wall_geometry_signature", "wall_triangles"])
		and _has_exact_keys(replacement, ["dispatch_order", "receiver_roles", "roof_object_key", "source_key", "wall_object_key"]),
		"building_3_parity_mismatch",
		"Building 3 nested behavior parity fields drifted.",
	):
		return false
	return _require(
		str(contract.get("schema_version", "")) == "ti.building-3-runtime-parity/1"
		and str(contract.get("parity_status", "")) == "exact_current_behavior_and_dependency_set_verified"
		and replacement.get("receiver_roles", []) == ["wall", "roof"]
		and str(replacement.get("dispatch_order", "")) == "target_specific_before_generic"
		and str(replacement.get("source_key", "")) == "w34313540"
		and str(replacement.get("wall_object_key", "")) == BUILDING_3_RECEIVER
		and str(replacement.get("roof_object_key", "")) == "building:w34313540:roof"
		and bool(geometry.get("horizontal_source_footprint_preserved", false))
		and bool(geometry.get("generated_bytes_unchanged", false))
		and int(geometry.get("wall_triangles", 0)) == 236
		and int(geometry.get("roof_triangles", 0)) == 675
		and int(geometry.get("topology_delta_triangles", 0)) == 766
		and str(geometry.get("profile_signature", "")) == "f82192fe9ebeb04a6da1222bcd84afd217f163ff6ce1cceed826a5d436dd1693"
		and str(geometry.get("wall_geometry_signature", "")) == "e03f830e6a41da16107b5db14bcb8a8ff9f43b46f9df89b1f157958cc68909d4"
		and str(geometry.get("roof_geometry_signature", "")) == "2dee9acf24616423230895d70827acb56c8f402a56ac1fe8e4a93d2409b34b63"
		and bool(collision.get("collision_matches_visible_geometry", false))
		and bool(collision.get("wall_world_solid", false))
		and bool(collision.get("roof_landing_world_solid", false))
		and str(collision.get("spray_ownership", "")) == "wall_only"
		and bool(facade.get("runtime_bound_to_wall_massing", false))
		and bool(facade.get("render_only", false))
		and str(facade.get("collision_owner", "")) == "massing_wall"
		and str(facade.get("deterministic_signature", "")) == "e0b30339bd2ca8642a7b49b5e6153f52017ec4a840e9b0dc1e3841f5373ca5f8",
		"building_3_parity_mismatch",
		"Building 3 wall/roof geometry, collision, landing, spray, or facade parity drifted.",
	)


func _validate_isle_house_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "isle_house_parity_mismatch", "Isle House exact-current Variant C low adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == "active-adapter:isle-house-variant-c:building-composite:w1249412094:w1282547787:wall"
		and str(adapter.get("source_key", "")) == "w1282547787"
		and str(adapter.get("attachment_kind", "")) == "active_isle_house_variant_c_low_part_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_composite_part_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_isle_house_variant_c"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and (adapter.get("runtime_assets", []) as Array).size() == 1
		and (adapter.get("runtime_asset_projections", []) as Array).size() == 3,
		"isle_house_parity_mismatch",
		"Isle House active adapter classification, source ownership, or fail-closed projection boundary drifted.",
	):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "repair_factory_sha256", "reviewed_factory_sha256"]), "isle_house_parity_mismatch", "Isle House active runtime contract fields drifted."):
		return false
	if not _require(
		_runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/resources/facades/isle_house_composite_repair_variant_c_standalone_v1.json", str(runtime_contract.get("config_sha256", "")))
		and str(runtime_contract.get("adapter_sha256", "")) == "e2767b01fab68d7f16ffe2e7f8e0313c711347e2006a72e028c19aaa2195b891"
		and str(runtime_contract.get("repair_factory_sha256", "")) == "4336e821e240b973f8d97e5cb46e17332b19dea03869abb1fa81b96a7e380582"
		and str(runtime_contract.get("reviewed_factory_sha256", "")) == "b24fd72cd12aa0c6c45a123f005fc834ea657c343e8332a872eae07fa017ace7"
		and _is_sha256(str(runtime_contract.get("dispatch_sha256", ""))),
		"isle_house_parity_mismatch",
		"Isle House live/config/factory/dispatch pins do not bind the reviewed exact-current state.",
	):
		return false
	return _validate_isle_house_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_isle_house_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["acceptance_contract", "geometry_contract", "ownership_contract", "replacement_contract", "schema_version", "truth_boundary"]), "isle_house_parity_mismatch", "Isle House behavior parity fields drifted."):
		return false
	var acceptance := contract.get("acceptance_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var ownership := contract.get("ownership_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	var truth := contract.get("truth_boundary", {}) as Dictionary
	if not _require(
		_has_exact_keys(acceptance, ["accepted_physical_unit_id", "independent_live_review_receipt_sha256", "numerator_effect", "part_source_keys_are_not_units", "reference_recognizable"])
		and _has_exact_keys(geometry, ["live_signature", "overlay_mesh_instances", "overlay_repair_signature", "overlay_surfaces", "overlay_triangles", "world_mesh_instances", "world_records", "world_shapes", "world_static_bodies", "world_surfaces", "world_topology_scope", "world_triangles"])
		and _has_exact_keys(ownership, ["decorative_collision_nodes", "decorative_navigation_nodes", "decorative_spray_nodes", "high_receiver_unchanged", "low_receiver_is_sole_collision_and_spray_owner"])
		and _has_exact_keys(replacement, ["rejected_overlay_fallback_allowed", "stacking_allowed", "target_receiver_key", "target_source_key"])
		and _has_exact_keys(truth, ["as_built_fidelity_claimed", "game_distinctive_claimed", "receiver_complete_inferred_from_art"]),
		"isle_house_parity_mismatch",
		"Isle House nested behavior parity fields drifted.",
	):
		return false
	return _require(
		str(contract.get("schema_version", "")) == "ti.isle-house-variant-c-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == ISLE_HOUSE_UNIT
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == ISLE_HOUSE_LIVE_REVIEW_RECEIPT_SHA256
		and int(acceptance.get("numerator_effect", -1)) == 1
		and acceptance.get("part_source_keys_are_not_units", []) == ["w1282547786", "w1282547787"]
		and bool(acceptance.get("reference_recognizable", false))
		and str(geometry.get("live_signature", "")) == ISLE_HOUSE_LIVE_SIGNATURE
		and str(geometry.get("overlay_repair_signature", "")) == ISLE_HOUSE_REPAIR_SIGNATURE
		and int(geometry.get("overlay_mesh_instances", -1)) == 7
		and int(geometry.get("overlay_surfaces", -1)) == 11
		and int(geometry.get("overlay_triangles", -1)) == 2242
		and str(geometry.get("world_topology_scope", "")) == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 944
		and int(geometry.get("world_surfaces", -1)) == 957
		and int(geometry.get("world_triangles", -1)) == 64572
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 466
		and int(ownership.get("decorative_collision_nodes", -1)) == 0
		and int(ownership.get("decorative_navigation_nodes", -1)) == 0
		and int(ownership.get("decorative_spray_nodes", -1)) == 0
		and bool(ownership.get("high_receiver_unchanged", false))
		and bool(ownership.get("low_receiver_is_sole_collision_and_spray_owner", false))
		and str(replacement.get("target_receiver_key", "")) == ISLE_HOUSE_LOW_RECEIVER
		and str(replacement.get("target_source_key", "")) == "w1282547787"
		and replacement.get("rejected_overlay_fallback_allowed") == false
		and replacement.get("stacking_allowed") == false
		and truth.get("as_built_fidelity_claimed") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("receiver_complete_inferred_from_art") == false,
		"isle_house_parity_mismatch",
		"Isle House receipt, signature, pre-B201 integration topology parity, ownership, replacement, or truth boundary drifted.",
	)


func _validate_navy_chapel_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "navy_chapel_parity_mismatch", "Navy Chapel exact-current paired adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == "active-adapter:navy-chapel-187:building:w291189336:wall"
		and str(adapter.get("source_key", "")) == "w291189336"
		and str(adapter.get("attachment_kind", "")) == "active_navy_chapel_187_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_navy_chapel_187_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"navy_chapel_parity_mismatch",
		"Navy Chapel active adapter classification, source ownership, or package boundary drifted.",
	):
		return false
	var actual_paths := []
	for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NAVY_CHAPEL_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "navy_chapel_parity_mismatch", "Navy Chapel active adapter does not contain its exact live/config/prototype/material set."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_sha256"]), "navy_chapel_parity_mismatch", "Navy Chapel active runtime contract fields drifted."):
		return false
	if not _require(
		_runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/facades/navy_chapel_187_live_replacement.gd", str(runtime_contract.get("adapter_sha256", "")))
		and _runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/resources/facades/navy_chapel_187_standalone_hero_prototype.json", str(runtime_contract.get("config_sha256", "")))
		and _runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd", str(runtime_contract.get("prototype_sha256", "")))
		and str(runtime_contract.get("adapter_sha256", "")) == "deffb5956d8e808565d1c557208647a89dff4730c15f97aa9b1085a087968cad"
		and str(runtime_contract.get("config_sha256", "")) == "c8f2ab09f3943a5ec8abea7cb9a108f49990bff1d83003c3b3622187a269dea2"
		and str(runtime_contract.get("prototype_sha256", "")) == "067c12e29c9fd352915ef2a501fcd7687b450081c79a4281d63bbfef1c19e7db"
		and _is_sha256(str(runtime_contract.get("dispatch_sha256", ""))),
		"navy_chapel_parity_mismatch",
		"Navy Chapel live/config/prototype/dispatch pins do not bind the reviewed exact-current state.",
	):
		return false
	return _validate_navy_chapel_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_navy_chapel_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["acceptance_contract", "geometry_contract", "ownership_contract", "replacement_contract", "schema_version", "truth_boundary"]), "navy_chapel_parity_mismatch", "Navy Chapel behavior parity fields drifted."):
		return false
	var acceptance := contract.get("acceptance_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var ownership := contract.get("ownership_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	var truth := contract.get("truth_boundary", {}) as Dictionary
	if not _require(
		_has_exact_keys(acceptance, ["accepted_physical_unit_id", "independent_live_review_receipt_sha256", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and _has_exact_keys(geometry, ["canonical_roof_record_sha256", "canonical_wall_record_sha256", "horizontal_source_footprint_preserved", "visual_geometry_signature", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "world_mesh_instances", "world_records", "world_shapes", "world_static_bodies", "world_surfaces", "world_topology_scope", "world_triangles"])
		and _has_exact_keys(ownership, ["live_ownership_signature", "navigation_owner_count", "roof_collision_triangles", "roof_is_wall_spray_receiver", "shape_count", "spray_owner_count", "structural_owner_count", "wall_collision_triangles", "wall_is_sole_spray_receiver"])
		and _has_exact_keys(replacement, ["actual_supplied_chunk_pair_required", "fallback_allowed", "generic_stack_allowed", "roof_object_key", "source_key", "wall_object_key"])
		and _has_exact_keys(truth, ["as_built_fidelity_claimed", "game_distinctive_claimed", "protected_runs_module_free", "receiver_complete_inferred_from_art", "side_count_and_spacing_are_production_inference"]),
		"navy_chapel_parity_mismatch",
		"Navy Chapel nested behavior parity fields drifted.",
	):
		return false
	return _require(
		str(contract.get("schema_version", "")) == "ti.navy-chapel-187-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w291189336"
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == NAVY_CHAPEL_LIVE_REVIEW_RECEIPT_SHA256
		and int(acceptance.get("numerator_effect", -1)) == 1
		and bool(acceptance.get("reference_recognizable", false))
		and bool(acceptance.get("wall_and_roof_are_one_physical_unit", false))
		and str(geometry.get("canonical_wall_record_sha256", "")) == "69769fef402b480f1626fdce47e6d4ad49ecb710dab2b2e7373e5efa5acf0080"
		and str(geometry.get("canonical_roof_record_sha256", "")) == "54bcd378997d0778bdaee432dc24ecdbb142c5dc5371166cf2d690ebb245b832"
		and bool(geometry.get("horizontal_source_footprint_preserved", false))
		and str(geometry.get("visual_geometry_signature", "")) == NAVY_CHAPEL_GEOMETRY_SIGNATURE
		and int(geometry.get("visual_mesh_instances", -1)) == 6
		and int(geometry.get("visual_surfaces", -1)) == 6
		and int(geometry.get("visual_triangles", -1)) == 540
		and str(geometry.get("world_topology_scope", "")) == PRE_B201_INTEGRATION_WORLD_TOPOLOGY_SCOPE
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 944
		and int(geometry.get("world_surfaces", -1)) == 957
		and int(geometry.get("world_triangles", -1)) == 64572
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 466
		and str(ownership.get("live_ownership_signature", "")) == NAVY_CHAPEL_OWNERSHIP_SIGNATURE
		and int(ownership.get("structural_owner_count", -1)) == 2
		and int(ownership.get("shape_count", -1)) == 2
		and int(ownership.get("spray_owner_count", -1)) == 1
		and int(ownership.get("navigation_owner_count", -1)) == 0
		and int(ownership.get("wall_collision_triangles", -1)) == 94
		and int(ownership.get("roof_collision_triangles", -1)) == 50
		and bool(ownership.get("wall_is_sole_spray_receiver", false))
		and ownership.get("roof_is_wall_spray_receiver") == false
		and str(replacement.get("source_key", "")) == "w291189336"
		and str(replacement.get("wall_object_key", "")) == NAVY_CHAPEL_RECEIVER
		and str(replacement.get("roof_object_key", "")) == "building:w291189336:roof"
		and bool(replacement.get("actual_supplied_chunk_pair_required", false))
		and replacement.get("fallback_allowed") == false
		and replacement.get("generic_stack_allowed") == false
		and truth.get("as_built_fidelity_claimed") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("receiver_complete_inferred_from_art") == false
		and bool(truth.get("protected_runs_module_free", false))
		and bool(truth.get("side_count_and_spacing_are_production_inference", false)),
		"navy_chapel_parity_mismatch",
		"Navy Chapel receipt, paired geometry, topology, ownership, replacement, or truth boundary drifted.",
	)


func _validate_d1_b201_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "d1_b201_parity_mismatch", "D1 B201 exact-current host-partition adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == "active-adapter:d1-b201-live:building:w34313545:wall"
		and str(adapter.get("source_key", "")) == "w34313545"
		and str(adapter.get("attachment_kind", "")) == "active_d1_b201_receiver_host_partition_attachment"
		and str(adapter.get("content_classification", "")) == "active_target_specific_receiver_host_partition_plus_render_only_attachment"
		and str(adapter.get("runtime_content_mode", "")) == "active_d1_b201_host_partition_attachment"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"d1_b201_parity_mismatch",
		"D1 B201 active adapter classification, source ownership, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 40,
		"d1_b201_parity_mismatch",
		"D1 B201 active receiver scope does not cover the exact 40-run direct wall receiver.",
	):
		return false
	var actual_paths := []
	for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := D1_B201_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "d1_b201_parity_mismatch", "D1 B201 active adapter does not contain its exact config/adapter/six-material closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256"]), "d1_b201_parity_mismatch", "D1 B201 active runtime contract fields drifted."):
		return false
	if not _require(
		_runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/facades/d1_b201_live_attachment.gd", str(runtime_contract.get("adapter_sha256", "")))
		and _runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/resources/facades/d1_current/d1_b201_live_attachment.json", str(runtime_contract.get("config_sha256", "")))
		and str(runtime_contract.get("adapter_sha256", "")) == "499f6d2657b593ee5b0801cf1205a2925a993f3b1836922d3656a6d00c51cc19"
		and str(runtime_contract.get("config_sha256", "")) == "0f3bf052688ec813b5fa58b077d74c963949574623fe4cf67c12c347e7257229"
		and str(runtime_contract.get("dispatch_sha256", "")) == D2_1441_BUILDER_SHA256,
		"d1_b201_parity_mismatch",
		"D1 B201 adapter/config/dispatch pins do not bind the exact independently reviewed bytes.",
	):
		return false
	return _validate_d1_b201_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_d1_b201_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["acceptance_contract", "geometry_contract", "ownership_contract", "replacement_contract", "schema_version", "truth_boundary"]), "d1_b201_parity_mismatch", "D1 B201 behavior parity fields drifted."):
		return false
	var acceptance := contract.get("acceptance_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var ownership := contract.get("ownership_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	var truth := contract.get("truth_boundary", {}) as Dictionary
	if not _require(
		_has_exact_keys(acceptance, ["accepted_physical_unit_id", "capture_time_recognition_metric", "evidence_manifest_sha256", "independent_live_review_receipt_sha256", "numerator_effect", "reference_recognizable"])
		and _has_exact_keys(geometry, ["canonical_roof_record_sha256", "canonical_wall_record_sha256", "decorative_box_instances", "decorative_geometry_signature", "decorative_mesh_instances", "decorative_surfaces", "decorative_triangles", "eligible_host_triangles", "host_triangles", "protected_host_triangles", "world_mesh_instances", "world_records", "world_shapes", "world_static_bodies", "world_surfaces", "world_topology_scope", "world_triangles"])
		and _has_exact_keys(ownership, ["decorative_collision_nodes", "decorative_navigation_nodes", "decorative_spray_nodes", "host_collision_owner_preserved", "host_mesh_preserved", "host_spray_owner_preserved", "navigation_owner_count", "shape_count", "spray_owner_count", "structural_owner_count"])
		and _has_exact_keys(replacement, ["actual_supplied_chunk_pair_required", "eligible_run_indices", "fallback_allowed", "host_material_partition", "protected_run_indices", "receiver_relative_render_only_attachment", "roof_object_key", "source_key", "stacking_allowed", "wall_object_key"])
		and _has_exact_keys(truth, ["as_built_fidelity_claimed", "counts_cadence_dimensions_are_production_inference", "game_distinctive_claimed", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "service_and_unobserved_sides_untouched"]),
		"d1_b201_parity_mismatch",
		"D1 B201 nested behavior parity fields drifted.",
	):
		return false
	return _require(
		str(contract.get("schema_version", "")) == "ti.d1-b201-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w34313545"
		and str(acceptance.get("capture_time_recognition_metric", "")) == "6/213"
		and str(acceptance.get("evidence_manifest_sha256", "")) == D1_B201_EVIDENCE_MANIFEST_SHA256
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == D1_B201_REVIEW_RECEIPT_SHA256
		and int(acceptance.get("numerator_effect", -1)) == 1
		and bool(acceptance.get("reference_recognizable", false))
		and str(geometry.get("canonical_wall_record_sha256", "")) == "024b2ed0af4de1a7e8456fcd171e1abc27a212dd72d054a9d9d1d487effa98b3"
		and str(geometry.get("canonical_roof_record_sha256", "")) == "53994e07ee99632a338d8c577427efac3ca3c584148f4d9ef92a251a49e589ff"
		and str(geometry.get("decorative_geometry_signature", "")) == D1_B201_DECORATIVE_SIGNATURE
		and int(geometry.get("decorative_mesh_instances", -1)) == 6
		and int(geometry.get("decorative_surfaces", -1)) == 6
		and int(geometry.get("decorative_box_instances", -1)) == 172
		and int(geometry.get("decorative_triangles", -1)) == 2064
		and int(geometry.get("host_triangles", -1)) == 80
		and int(geometry.get("eligible_host_triangles", -1)) == 20
		and int(geometry.get("protected_host_triangles", -1)) == 60
		and str(geometry.get("world_topology_scope", "")) == PRE_B225_INTEGRATION_WORLD_TOPOLOGY_SCOPE
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 950
		and int(geometry.get("world_surfaces", -1)) == 964
		and int(geometry.get("world_triangles", -1)) == 66636
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 466
		and int(ownership.get("structural_owner_count", -1)) == 1
		and int(ownership.get("shape_count", -1)) == 1
		and int(ownership.get("spray_owner_count", -1)) == 1
		and int(ownership.get("navigation_owner_count", -1)) == 0
		and int(ownership.get("decorative_collision_nodes", -1)) == 0
		and int(ownership.get("decorative_navigation_nodes", -1)) == 0
		and int(ownership.get("decorative_spray_nodes", -1)) == 0
		and bool(ownership.get("host_mesh_preserved", false))
		and bool(ownership.get("host_collision_owner_preserved", false))
		and bool(ownership.get("host_spray_owner_preserved", false))
		and str(replacement.get("source_key", "")) == "w34313545"
		and str(replacement.get("wall_object_key", "")) == D1_B201_RECEIVER
		and str(replacement.get("roof_object_key", "")) == "building:w34313545:roof"
		and _int_array_matches(replacement.get("eligible_run_indices", []) as Array, range(0, 10))
		and _int_array_matches(replacement.get("protected_run_indices", []) as Array, range(10, 40))
		and bool(replacement.get("actual_supplied_chunk_pair_required", false))
		and bool(replacement.get("host_material_partition", false))
		and bool(replacement.get("receiver_relative_render_only_attachment", false))
		and replacement.get("fallback_allowed") == false
		and replacement.get("stacking_allowed") == false
		and truth.get("as_built_fidelity_claimed") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("receiver_complete_inferred_from_art") == false
		and bool(truth.get("counts_cadence_dimensions_are_production_inference", false))
		and truth.get("reference_pixels_packaged") == false
		and bool(truth.get("service_and_unobserved_sides_untouched", false)),
		"d1_b201_parity_mismatch",
		"D1 B201 receipt, host partition, topology, ownership, replacement, or truth boundary drifted.",
	)


func _validate_d1_b225_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "d1_b225_parity_mismatch", "D1 B225 exact-current host-partition adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == "active-adapter:d1-b225-live:building:w95934119:wall"
		and str(adapter.get("source_key", "")) == "w95934119"
		and str(adapter.get("attachment_kind", "")) == "active_d1_b225_receiver_host_partition_attachment"
		and str(adapter.get("content_classification", "")) == "active_target_specific_receiver_host_partition_plus_render_only_attachment"
		and str(adapter.get("runtime_content_mode", "")) == "active_d1_b225_host_partition_attachment"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"d1_b225_parity_mismatch",
		"D1 B225 active adapter classification, source ownership, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 14,
		"d1_b225_parity_mismatch",
		"D1 B225 active receiver scope does not cover the exact 14-run direct wall receiver.",
	):
		return false
	var actual_paths := []
	for asset_value: Variant in adapter.get("runtime_assets", []) as Array:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := D1_B225_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "d1_b225_parity_mismatch", "D1 B225 active adapter does not contain its exact config/adapter/material/texture closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256"]), "d1_b225_parity_mismatch", "D1 B225 active runtime contract fields drifted."):
		return false
	if not _require(
		_runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/scripts/world/facades/d1_b225_live_attachment.gd", str(runtime_contract.get("adapter_sha256", "")))
		and _runtime_asset_match(adapter.get("runtime_assets", []) as Array, "res://game/resources/facades/d1_current/d1_b225_live_attachment.json", str(runtime_contract.get("config_sha256", "")))
		and str(runtime_contract.get("adapter_sha256", "")) == "4b1defd92a77b23de692437f044dfaa579fa2ee5b3dee77465ec8404f1644ac9"
		and str(runtime_contract.get("config_sha256", "")) == "80b42c33fce84361aa7512f64305f5bff273e8fed95640ca4f9c19d49d55621d"
		and str(runtime_contract.get("dispatch_sha256", "")) == D2_1441_BUILDER_SHA256,
		"d1_b225_parity_mismatch",
		"D1 B225 adapter/config/dispatch pins do not bind the exact independently reviewed bytes.",
	):
		return false
	return _validate_d1_b225_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_d1_b225_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["acceptance_contract", "geometry_contract", "ownership_contract", "replacement_contract", "schema_version", "truth_boundary"]), "d1_b225_parity_mismatch", "D1 B225 behavior parity fields drifted."):
		return false
	var acceptance := contract.get("acceptance_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var ownership := contract.get("ownership_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	var truth := contract.get("truth_boundary", {}) as Dictionary
	if not _require(
		_has_exact_keys(acceptance, ["accepted_physical_unit_id", "capture_time_recognition_metric", "evidence_manifest_sha256", "evidence_tree_sha256", "independent_live_review_receipt_sha256", "numerator_effect", "reference_recognizable"])
		and _has_exact_keys(geometry, ["canonical_roof_record_sha256", "canonical_wall_record_sha256", "decorative_box_instances", "decorative_geometry_signature", "decorative_mesh_instances", "decorative_surfaces", "decorative_triangles", "eligible_host_triangles", "host_triangles", "protected_host_triangles", "world_mesh_instances", "world_records", "world_shapes", "world_static_bodies", "world_surfaces", "world_topology_scope", "world_triangles"])
		and _has_exact_keys(ownership, ["decorative_collision_nodes", "decorative_navigation_nodes", "decorative_spray_nodes", "host_collision_owner_preserved", "host_mesh_preserved", "host_spray_owner_preserved", "navigation_owner_count", "shape_count", "spray_owner_count", "structural_owner_count"])
		and _has_exact_keys(replacement, ["actual_supplied_chunk_pair_required", "eligible_run_indices", "fallback_allowed", "host_material_partition", "protected_run_indices", "receiver_relative_render_only_attachment", "roof_object_key", "source_key", "stacking_allowed", "wall_object_key"])
		and _has_exact_keys(truth, ["as_built_fidelity_claimed", "counts_cadence_dimensions_are_production_inference", "game_distinctive_claimed", "lower_and_unobserved_sides_untouched", "receiver_complete_inferred_from_art", "reference_pixels_packaged"]),
		"d1_b225_parity_mismatch",
		"D1 B225 nested behavior parity fields drifted.",
	):
		return false
	return _require(
		str(contract.get("schema_version", "")) == "ti.d1-b225-production-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934119"
		and str(acceptance.get("capture_time_recognition_metric", "")) == "7/213"
		and str(acceptance.get("evidence_manifest_sha256", "")) == D1_B225_EVIDENCE_MANIFEST_SHA256
		and str(acceptance.get("evidence_tree_sha256", "")) == D1_B225_EVIDENCE_TREE_SHA256
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == D1_B225_REVIEW_RECEIPT_SHA256
		and int(acceptance.get("numerator_effect", -1)) == 1
		and bool(acceptance.get("reference_recognizable", false))
		and str(geometry.get("canonical_wall_record_sha256", "")) == "7950095b20ea50b989f7f111e6e4bfd45cdc42cda85ac3e0f3c8cd044c836722"
		and str(geometry.get("canonical_roof_record_sha256", "")) == "338afe9681244b8deca0b4f87891a8a91069002b36bc7a9c4fd8564b420778c0"
		and str(geometry.get("decorative_geometry_signature", "")) == D1_B225_DECORATIVE_SIGNATURE
		and int(geometry.get("decorative_mesh_instances", -1)) == 2
		and int(geometry.get("decorative_surfaces", -1)) == 2
		and int(geometry.get("decorative_box_instances", -1)) == 90
		and int(geometry.get("decorative_triangles", -1)) == 1080
		and int(geometry.get("host_triangles", -1)) == 28
		and int(geometry.get("eligible_host_triangles", -1)) == 8
		and int(geometry.get("protected_host_triangles", -1)) == 20
		and str(geometry.get("world_topology_scope", "")) == PRE_D2_1441_INTEGRATION_WORLD_TOPOLOGY_SCOPE
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 952
		and int(geometry.get("world_surfaces", -1)) == 967
		and int(geometry.get("world_triangles", -1)) == 67716
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 466
		and int(ownership.get("structural_owner_count", -1)) == 1
		and int(ownership.get("shape_count", -1)) == 1
		and int(ownership.get("spray_owner_count", -1)) == 1
		and int(ownership.get("navigation_owner_count", -1)) == 0
		and int(ownership.get("decorative_collision_nodes", -1)) == 0
		and int(ownership.get("decorative_navigation_nodes", -1)) == 0
		and int(ownership.get("decorative_spray_nodes", -1)) == 0
		and bool(ownership.get("host_mesh_preserved", false))
		and bool(ownership.get("host_collision_owner_preserved", false))
		and bool(ownership.get("host_spray_owner_preserved", false))
		and str(replacement.get("source_key", "")) == "w95934119"
		and str(replacement.get("wall_object_key", "")) == D1_B225_RECEIVER
		and str(replacement.get("roof_object_key", "")) == "building:w95934119:roof"
		and _int_array_matches(replacement.get("eligible_run_indices", []) as Array, range(10, 14))
		and _int_array_matches(replacement.get("protected_run_indices", []) as Array, range(0, 10))
		and bool(replacement.get("actual_supplied_chunk_pair_required", false))
		and bool(replacement.get("host_material_partition", false))
		and bool(replacement.get("receiver_relative_render_only_attachment", false))
		and replacement.get("fallback_allowed") == false
		and replacement.get("stacking_allowed") == false
		and truth.get("as_built_fidelity_claimed") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("receiver_complete_inferred_from_art") == false
		and bool(truth.get("counts_cadence_dimensions_are_production_inference", false))
		and truth.get("reference_pixels_packaged") == false
		and bool(truth.get("lower_and_unobserved_sides_untouched", false)),
		"d1_b225_parity_mismatch",
		"D1 B225 frozen evidence receipt, host partition, pre-D2 topology, ownership, replacement, or truth boundary drifted.",
	)


func _validate_d2_1441_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "d2_1441_parity_mismatch", "D2 1441 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == D2_1441_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w95934105"
		and str(adapter.get("receiver_key", "")) == D2_1441_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_d2_1441_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_d2_1441_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"d2_1441_parity_mismatch",
		"D2 1441 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 16,
		"d2_1441_parity_mismatch",
		"D2 1441 active receiver scope does not cover the exact 16-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := D2_1441_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "d2_1441_parity_mismatch", "D2 1441 active adapter does not contain its exact 13-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"d2_1441_parity_mismatch",
		"D2 1441 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == D2_1441_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == D2_1441_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == D2_1441_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == D2_1441_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == D2_1441_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == D2_1441_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd", D2_1441_ADAPTER_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d2_1441_chinook_live_replacement.json", D2_1441_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd", D2_1441_PROTOTYPE_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json", D2_1441_PROTOTYPE_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D2_1441_SITE_KIT_SHA256),
		"d2_1441_parity_mismatch",
		"D2 1441 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _validate_d2_1441_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_d2_1441_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["acceptance_contract", "geometry_contract", "ownership_contract", "replacement_contract", "schema_version", "truth_boundary"]), "d2_1441_parity_mismatch", "D2 1441 behavior parity fields drifted."):
		return false
	var acceptance := contract.get("acceptance_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var ownership := contract.get("ownership_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	var truth := contract.get("truth_boundary", {}) as Dictionary
	if not _require(
		_has_exact_keys(acceptance, ["accepted_physical_unit_id", "capture_time_recognition_metric", "evidence_manifest_sha256", "evidence_tree_sha256", "independent_live_review_receipt_sha256", "mechanical_review_receipt_sha256", "motion_telemetry_manifest_sha256", "numerator_effect", "package_verification_receipt_sha256", "reference_recognizable", "visual_motion_manifest_sha256", "wall_and_roof_are_one_physical_unit"])
		and _has_exact_keys(geometry, ["canonical_roof_record_sha256", "canonical_wall_record_sha256", "horizontal_source_footprint_preserved", "topology_delta_mesh_instances", "topology_delta_records", "topology_delta_shapes", "topology_delta_static_bodies", "topology_delta_surfaces", "topology_delta_triangles", "visual_geometry_signature", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "world_mesh_instances", "world_records", "world_shapes", "world_static_bodies", "world_surfaces", "world_topology_scope", "world_triangles"])
		and _has_exact_keys(ownership, ["decorative_collision_triangles", "decorative_navigation_nodes", "decorative_relief_triangles", "live_ownership_signature", "navigation_owner_count", "roof_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "shape_count", "spray_owner_count", "structural_owner_count", "wall_collision_triangles", "wall_is_sole_spray_receiver"])
		and _has_exact_keys(replacement, ["actual_supplied_chunk_pair_required", "fallback_allowed", "generic_stack_allowed", "mapped_public_run_indices", "partial_pair_allowed", "protected_run_indices", "roof_object_key", "source_key", "wall_object_key"])
		and _has_exact_keys(truth, ["as_built_fidelity_claimed", "capture_time_candidate_promoted", "capture_time_recognition_credit", "game_distinctive_claimed", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference", "unobserved_sides_protected"]),
		"d2_1441_parity_mismatch",
		"D2 1441 nested behavior parity fields drifted.",
	):
		return false
	return _require(
		str(contract.get("schema_version", "")) == "ti.d2-1441-production-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934105"
		and str(acceptance.get("capture_time_recognition_metric", "")) == "8/213"
		and str(acceptance.get("evidence_manifest_sha256", "")) == D2_1441_EVIDENCE_MANIFEST_SHA256
		and str(acceptance.get("motion_telemetry_manifest_sha256", "")) == D2_1441_MOTION_TELEMETRY_MANIFEST_SHA256
		and str(acceptance.get("visual_motion_manifest_sha256", "")) == D2_1441_VISUAL_MOTION_MANIFEST_SHA256
		and str(acceptance.get("evidence_tree_sha256", "")) == D2_1441_EVIDENCE_TREE_SHA256
		and str(acceptance.get("package_verification_receipt_sha256", "")) == D2_1441_PACKAGE_RECEIPT_SHA256
		and str(acceptance.get("mechanical_review_receipt_sha256", "")) == D2_1441_MECHANICAL_REVIEW_SHA256
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == D2_1441_VISUAL_REVIEW_SHA256
		and int(acceptance.get("numerator_effect", -1)) == 1
		and bool(acceptance.get("reference_recognizable", false))
		and bool(acceptance.get("wall_and_roof_are_one_physical_unit", false))
		and str(geometry.get("canonical_wall_record_sha256", "")) == "00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c"
		and str(geometry.get("canonical_roof_record_sha256", "")) == "e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55"
		and bool(geometry.get("horizontal_source_footprint_preserved", false))
		and int(geometry.get("topology_delta_records", -1)) == 0
		and int(geometry.get("topology_delta_mesh_instances", -1)) == 7
		and int(geometry.get("topology_delta_surfaces", -1)) == 7
		and int(geometry.get("topology_delta_triangles", -1)) == 1536
		and int(geometry.get("topology_delta_static_bodies", -1)) == 0
		and int(geometry.get("topology_delta_shapes", -1)) == 0
		and str(geometry.get("visual_geometry_signature", "")) == D2_1441_GEOMETRY_SIGNATURE
		and int(geometry.get("visual_mesh_instances", -1)) == 9
		and int(geometry.get("visual_surfaces", -1)) == 9
		and int(geometry.get("visual_triangles", -1)) == 1578
		and str(geometry.get("world_topology_scope", "")) == PRE_D2_1439_INTEGRATION_WORLD_TOPOLOGY_SCOPE
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 959
		and int(geometry.get("world_surfaces", -1)) == 974
		and int(geometry.get("world_triangles", -1)) == 70692
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 466
		and str(ownership.get("live_ownership_signature", "")) == D2_1441_OWNERSHIP_SIGNATURE
		and int(ownership.get("structural_owner_count", -1)) == 2
		and int(ownership.get("shape_count", -1)) == 2
		and int(ownership.get("spray_owner_count", -1)) == 1
		and int(ownership.get("navigation_owner_count", -1)) == 0
		and int(ownership.get("wall_collision_triangles", -1)) == 32
		and int(ownership.get("roof_collision_triangles", -1)) == 10
		and int(ownership.get("decorative_relief_triangles", -1)) == 1536
		and int(ownership.get("decorative_collision_triangles", -1)) == 0
		and int(ownership.get("decorative_navigation_nodes", -1)) == 0
		and bool(ownership.get("wall_is_sole_spray_receiver", false))
		and ownership.get("roof_is_wall_spray_receiver") == false
		and bool(ownership.get("roof_world_solid_landing", false))
		and str(replacement.get("source_key", "")) == "w95934105"
		and str(replacement.get("wall_object_key", "")) == D2_1441_RECEIVER
		and str(replacement.get("roof_object_key", "")) == "building:w95934105:roof"
		and _int_array_matches(replacement.get("mapped_public_run_indices", []) as Array, [10, 12, 13, 15])
		and _int_array_matches(replacement.get("protected_run_indices", []) as Array, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14])
		and bool(replacement.get("actual_supplied_chunk_pair_required", false))
		and replacement.get("fallback_allowed") == false
		and replacement.get("generic_stack_allowed") == false
		and replacement.get("partial_pair_allowed") == false
		and truth.get("as_built_fidelity_claimed") == false
		and truth.get("capture_time_candidate_promoted") == false
		and truth.get("capture_time_recognition_credit") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("reference_pixels_packaged") == false
		and truth.get("receiver_complete_inferred_from_art") == false
		and bool(truth.get("unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference", false))
		and bool(truth.get("unobserved_sides_protected", false)),
		"d2_1441_parity_mismatch",
		"D2 1441 frozen capture-time evidence, paired topology, ownership, replacement, or truth boundary drifted.",
	)


func _validate_d2_1441_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd", D2_1441_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd", D2_1441_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D2_1441_SITE_KIT_SHA256),
		"d2_1441_parity_mismatch",
		"D2 1441 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)


func _validate_d2_1439_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "d2_1439_parity_mismatch", "D2 1439 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == D2_1439_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w95934144"
		and str(adapter.get("receiver_key", "")) == D2_1439_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_d2_1439_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_d2_1439_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"d2_1439_parity_mismatch",
		"D2 1439 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 24,
		"d2_1439_parity_mismatch",
		"D2 1439 active receiver scope does not cover the exact 24-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := D2_1439_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "d2_1439_parity_mismatch", "D2 1439 active adapter does not contain its exact 13-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"d2_1439_parity_mismatch",
		"D2 1439 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == D2_1439_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == D2_1439_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == D2_1439_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == D2_1439_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == D2_1439_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == D2_1439_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d2_1439_chinook_quality_v2_live_replacement.gd", D2_1439_ADAPTER_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d2_1439_chinook_quality_v2_live_replacement.json", D2_1439_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d2_1439_chinook_quality_v2_prototype.gd", D2_1439_PROTOTYPE_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d2_1439_chinook_quality_v2_prototype.json", D2_1439_PROTOTYPE_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D2_1439_SITE_KIT_SHA256),
		"d2_1439_parity_mismatch",
		"D2 1439 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _validate_d2_1439_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_d2_1444_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "d2_1444_parity_mismatch", "D2 1444 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == D2_1444_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w95934117"
		and str(adapter.get("receiver_key", "")) == D2_1444_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_d2_1444_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_d2_1444_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"d2_1444_parity_mismatch",
		"D2 1444 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 22,
		"d2_1444_parity_mismatch",
		"D2 1444 active receiver scope does not cover the exact 22-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := D2_1444_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "d2_1444_parity_mismatch", "D2 1444 active adapter does not contain its exact 13-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"d2_1444_parity_mismatch",
		"D2 1444 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == D2_1444_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == D2_1444_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == D2_1444_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == D2_1444_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == D2_1444_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == D2_1444_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d2_1444_croaker_quality_v2_live_replacement.gd", D2_1444_ADAPTER_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d2_1444_croaker_quality_v2_live_replacement.json", D2_1444_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d2_1444_croaker_quality_v2_prototype.gd", D2_1444_PROTOTYPE_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d2_1444_croaker_quality_v2_prototype.json", D2_1444_PROTOTYPE_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D2_1444_SITE_KIT_SHA256),
		"d2_1444_parity_mismatch",
		"D2 1444 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _validate_d2_1444_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_d2_1439_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["acceptance_contract", "geometry_contract", "ownership_contract", "replacement_contract", "schema_version", "truth_boundary"]), "d2_1439_parity_mismatch", "D2 1439 behavior parity fields drifted."):
		return false
	var acceptance := contract.get("acceptance_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var ownership := contract.get("ownership_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	var truth := contract.get("truth_boundary", {}) as Dictionary
	if not _require(
		_has_exact_keys(acceptance, ["accepted_physical_unit_id", "capture_time_recognition_metric", "evidence_manifest_sha256", "evidence_tree_sha256", "independent_live_review_receipt_sha256", "mechanical_review_receipt_sha256", "motion_telemetry_manifest_sha256", "numerator_effect", "package_verification_receipt_sha256", "reference_recognizable", "visual_motion_manifest_sha256", "wall_and_roof_are_one_physical_unit"])
		and _has_exact_keys(geometry, ["canonical_roof_record_sha256", "canonical_wall_record_sha256", "horizontal_source_footprint_preserved", "topology_delta_mesh_instances", "topology_delta_records", "topology_delta_shapes", "topology_delta_static_bodies", "topology_delta_surfaces", "topology_delta_triangles", "visual_geometry_signature", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "world_mesh_instances", "world_records", "world_shapes", "world_static_bodies", "world_surfaces", "world_topology_scope", "world_triangles"])
		and _has_exact_keys(ownership, ["eligible_exterior_collision_triangles", "noneligible_closed_recess_collision_triangles", "wall_shape_order", "closed_recess_render_layer", "wall_decal_cull_mask", "decorative_collision_triangles", "decorative_navigation_nodes", "decorative_relief_triangles", "live_ownership_signature", "navigation_owner_count", "roof_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "shape_count", "spray_owner_count", "structural_owner_count", "wall_collision_triangles", "wall_is_sole_spray_receiver"])
		and _has_exact_keys(replacement, ["actual_supplied_chunk_pair_required", "fallback_allowed", "generic_stack_allowed", "mapped_public_run_indices", "partial_pair_allowed", "protected_run_indices", "roof_object_key", "source_key", "wall_object_key"])
		and _has_exact_keys(truth, ["as_built_fidelity_claimed", "capture_time_candidate_promoted", "capture_time_recognition_credit", "game_distinctive_claimed", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference", "unobserved_sides_protected"]),
		"d2_1439_parity_mismatch",
		"D2 1439 nested behavior parity fields drifted.",
	):
		return false
	return _require(
		str(contract.get("schema_version", "")) == "ti.d2-1439-production-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934144"
		and str(acceptance.get("capture_time_recognition_metric", "")) == "9/213"
		and str(acceptance.get("evidence_manifest_sha256", "")) == D2_1439_EVIDENCE_MANIFEST_SHA256
		and str(acceptance.get("motion_telemetry_manifest_sha256", "")) == D2_1439_MOTION_TELEMETRY_MANIFEST_SHA256
		and str(acceptance.get("visual_motion_manifest_sha256", "")) == D2_1439_VISUAL_MOTION_MANIFEST_SHA256
		and str(acceptance.get("evidence_tree_sha256", "")) == D2_1439_EVIDENCE_TREE_SHA256
		and str(acceptance.get("package_verification_receipt_sha256", "")) == D2_1439_PACKAGE_RECEIPT_SHA256
		and str(acceptance.get("mechanical_review_receipt_sha256", "")) == D2_1439_MECHANICAL_REVIEW_SHA256
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == D2_1439_VISUAL_REVIEW_SHA256
		and int(acceptance.get("numerator_effect", -1)) == 1
		and bool(acceptance.get("reference_recognizable", false))
		and bool(acceptance.get("wall_and_roof_are_one_physical_unit", false))
		and str(geometry.get("canonical_wall_record_sha256", "")) == "0a0b5d7c002a3364714343704404e3e37fa1e55461c3bfae6ae0766d59bb8b11"
		and str(geometry.get("canonical_roof_record_sha256", "")) == "ab98ae1442174841c0d9ae3aeb344991e73c2b85bf07252d2dc12d834ac0f8c0"
		and bool(geometry.get("horizontal_source_footprint_preserved", false))
		and int(geometry.get("topology_delta_records", -1)) == 0
		and int(geometry.get("topology_delta_mesh_instances", -1)) == 9
		and int(geometry.get("topology_delta_surfaces", -1)) == 9
		and int(geometry.get("topology_delta_triangles", -1)) == 464
		and int(geometry.get("topology_delta_static_bodies", -1)) == 0
		and int(geometry.get("topology_delta_shapes", -1)) == 1
		and str(geometry.get("visual_geometry_signature", "")) == D2_1439_GEOMETRY_SIGNATURE
		and int(geometry.get("visual_mesh_instances", -1)) == 11
		and int(geometry.get("visual_surfaces", -1)) == 11
		and int(geometry.get("visual_triangles", -1)) == 522
		and str(geometry.get("world_topology_scope", "")) == PRE_D2_1444_INTEGRATION_WORLD_TOPOLOGY_SCOPE
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 968
		and int(geometry.get("world_surfaces", -1)) == 983
		and int(geometry.get("world_triangles", -1)) == 71156
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 467
		and str(ownership.get("live_ownership_signature", "")) == D2_1439_OWNERSHIP_SIGNATURE
		and int(ownership.get("structural_owner_count", -1)) == 2
		and int(ownership.get("shape_count", -1)) == 3
		and int(ownership.get("spray_owner_count", -1)) == 1
		and int(ownership.get("navigation_owner_count", -1)) == 0
		and int(ownership.get("wall_collision_triangles", -1)) == 92
		and int(ownership.get("eligible_exterior_collision_triangles", -1)) == 62
		and int(ownership.get("noneligible_closed_recess_collision_triangles", -1)) == 30
		and ownership.get("wall_shape_order", []) == ["eligible_exterior", "noneligible_closed_recess"]
		and int(ownership.get("closed_recess_render_layer", -1)) == 1
		and int(ownership.get("wall_decal_cull_mask", -1)) == 2
		and int(ownership.get("roof_collision_triangles", -1)) == 10
		and int(ownership.get("decorative_relief_triangles", -1)) == 420
		and int(ownership.get("decorative_collision_triangles", -1)) == 0
		and int(ownership.get("decorative_navigation_nodes", -1)) == 0
		and bool(ownership.get("wall_is_sole_spray_receiver", false))
		and ownership.get("roof_is_wall_spray_receiver") == false
		and bool(ownership.get("roof_world_solid_landing", false))
		and str(replacement.get("source_key", "")) == "w95934144"
		and str(replacement.get("wall_object_key", "")) == D2_1439_RECEIVER
		and str(replacement.get("roof_object_key", "")) == "building:w95934144:roof"
		and _int_array_matches(replacement.get("mapped_public_run_indices", []) as Array, [11, 12, 16, 17, 18, 19, 22, 23])
		and _int_array_matches(replacement.get("protected_run_indices", []) as Array, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 20, 21])
		and bool(replacement.get("actual_supplied_chunk_pair_required", false))
		and replacement.get("fallback_allowed") == false
		and replacement.get("generic_stack_allowed") == false
		and replacement.get("partial_pair_allowed") == false
		and truth.get("as_built_fidelity_claimed") == false
		and truth.get("capture_time_candidate_promoted") == false
		and truth.get("capture_time_recognition_credit") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("reference_pixels_packaged") == false
		and truth.get("receiver_complete_inferred_from_art") == false
		and bool(truth.get("unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference", false))
		and bool(truth.get("unobserved_sides_protected", false)),
		"d2_1439_parity_mismatch",
		"D2 1439 frozen capture-time evidence, paired topology, ownership, replacement, or truth boundary drifted.",
	)


func _validate_d2_1444_behavior_contract(contract: Dictionary) -> bool:
	if not _require(_has_exact_keys(contract, ["acceptance_contract", "geometry_contract", "ownership_contract", "replacement_contract", "schema_version", "truth_boundary"]), "d2_1444_parity_mismatch", "D2 1444 behavior parity fields drifted."):
		return false
	var acceptance := contract.get("acceptance_contract", {}) as Dictionary
	var geometry := contract.get("geometry_contract", {}) as Dictionary
	var ownership := contract.get("ownership_contract", {}) as Dictionary
	var replacement := contract.get("replacement_contract", {}) as Dictionary
	var truth := contract.get("truth_boundary", {}) as Dictionary
	if not _require(
		_has_exact_keys(acceptance, ["accepted_physical_unit_id", "capture_time_recognition_metric", "evidence_manifest_sha256", "evidence_tree_sha256", "independent_live_review_receipt_sha256", "mechanical_review_receipt_sha256", "motion_telemetry_manifest_sha256", "numerator_effect", "package_verification_receipt_sha256", "reference_recognizable", "visual_motion_manifest_sha256", "wall_and_roof_are_one_physical_unit"])
		and _has_exact_keys(geometry, ["canonical_roof_record_sha256", "canonical_wall_record_sha256", "horizontal_source_footprint_preserved", "topology_delta_mesh_instances", "topology_delta_records", "topology_delta_shapes", "topology_delta_static_bodies", "topology_delta_surfaces", "topology_delta_triangles", "visual_geometry_signature", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "world_mesh_instances", "world_records", "world_shapes", "world_static_bodies", "world_surfaces", "world_topology_scope", "world_triangles"])
		and _has_exact_keys(ownership, ["eligible_exterior_collision_triangles", "noneligible_closed_recess_collision_triangles", "wall_shape_order", "closed_recess_render_layer", "wall_decal_cull_mask", "decorative_collision_triangles", "decorative_navigation_nodes", "decorative_relief_triangles", "live_ownership_signature", "navigation_owner_count", "roof_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "shape_count", "spray_owner_count", "structural_owner_count", "wall_collision_triangles", "wall_is_sole_spray_receiver"])
		and _has_exact_keys(replacement, ["actual_supplied_chunk_pair_required", "fallback_allowed", "generic_stack_allowed", "mapped_public_run_indices", "partial_pair_allowed", "protected_run_indices", "roof_object_key", "source_key", "wall_object_key"])
		and _has_exact_keys(truth, ["as_built_fidelity_claimed", "capture_time_candidate_promoted", "capture_time_recognition_credit", "game_distinctive_claimed", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference", "unobserved_sides_protected"]),
		"d2_1444_parity_mismatch",
		"D2 1444 nested behavior parity fields drifted.",
	):
		return false
	return _require(
		str(contract.get("schema_version", "")) == "ti.d2-1444-production-live-parity/1"
		and str(acceptance.get("accepted_physical_unit_id", "")) == "physical-building:w95934117"
		and str(acceptance.get("capture_time_recognition_metric", "")) == "9/213"
		and str(acceptance.get("evidence_manifest_sha256", "")) == D2_1444_EVIDENCE_MANIFEST_SHA256
		and str(acceptance.get("motion_telemetry_manifest_sha256", "")) == D2_1444_MOTION_TELEMETRY_MANIFEST_SHA256
		and str(acceptance.get("visual_motion_manifest_sha256", "")) == D2_1444_VISUAL_MOTION_MANIFEST_SHA256
		and str(acceptance.get("evidence_tree_sha256", "")) == D2_1444_EVIDENCE_TREE_SHA256
		and str(acceptance.get("package_verification_receipt_sha256", "")) == D2_1444_PACKAGE_RECEIPT_SHA256
		and str(acceptance.get("mechanical_review_receipt_sha256", "")) == D2_1444_MECHANICAL_REVIEW_SHA256
		and str(acceptance.get("independent_live_review_receipt_sha256", "")) == D2_1444_VISUAL_REVIEW_SHA256
		and int(acceptance.get("numerator_effect", -1)) == 1
		and bool(acceptance.get("reference_recognizable", false))
		and bool(acceptance.get("wall_and_roof_are_one_physical_unit", false))
		and str(geometry.get("canonical_wall_record_sha256", "")) == "5a872a7e700aec63a2c276bb28c341e3f501ac8122f51267b05fb8a620d15950"
		and str(geometry.get("canonical_roof_record_sha256", "")) == "0119a96ef2f8baf3e7a66a3db952cfd34930490b86dd25bf3693472728dadae1"
		and bool(geometry.get("horizontal_source_footprint_preserved", false))
		and int(geometry.get("topology_delta_records", -1)) == 0
		and int(geometry.get("topology_delta_mesh_instances", -1)) == 9
		and int(geometry.get("topology_delta_surfaces", -1)) == 9
		and int(geometry.get("topology_delta_triangles", -1)) == 672
		and int(geometry.get("topology_delta_static_bodies", -1)) == 0
		and int(geometry.get("topology_delta_shapes", -1)) == 1
		and str(geometry.get("visual_geometry_signature", "")) == D2_1444_GEOMETRY_SIGNATURE
		and int(geometry.get("visual_mesh_instances", -1)) == 11
		and int(geometry.get("visual_surfaces", -1)) == 11
		and int(geometry.get("visual_triangles", -1)) == 726
		and str(geometry.get("world_topology_scope", "")) == "pre_d5_batch_integration_live_parity"
		and int(geometry.get("world_records", -1)) == 735
		and int(geometry.get("world_mesh_instances", -1)) == 977
		and int(geometry.get("world_surfaces", -1)) == 992
		and int(geometry.get("world_triangles", -1)) == 71828
		and int(geometry.get("world_static_bodies", -1)) == 466
		and int(geometry.get("world_shapes", -1)) == 468
		and str(ownership.get("live_ownership_signature", "")) == D2_1444_OWNERSHIP_SIGNATURE
		and int(ownership.get("structural_owner_count", -1)) == 2
		and int(ownership.get("shape_count", -1)) == 3
		and int(ownership.get("spray_owner_count", -1)) == 1
		and int(ownership.get("navigation_owner_count", -1)) == 0
		and int(ownership.get("wall_collision_triangles", -1)) == 104
		and int(ownership.get("eligible_exterior_collision_triangles", -1)) == 64
		and int(ownership.get("noneligible_closed_recess_collision_triangles", -1)) == 40
		and ownership.get("wall_shape_order", []) == ["eligible_exterior", "noneligible_closed_recess"]
		and int(ownership.get("closed_recess_render_layer", -1)) == 1
		and int(ownership.get("wall_decal_cull_mask", -1)) == 2
		and int(ownership.get("roof_collision_triangles", -1)) == 10
		and int(ownership.get("decorative_relief_triangles", -1)) == 612
		and int(ownership.get("decorative_collision_triangles", -1)) == 0
		and int(ownership.get("decorative_navigation_nodes", -1)) == 0
		and bool(ownership.get("wall_is_sole_spray_receiver", false))
		and ownership.get("roof_is_wall_spray_receiver") == false
		and bool(ownership.get("roof_world_solid_landing", false))
		and str(replacement.get("source_key", "")) == "w95934117"
		and str(replacement.get("wall_object_key", "")) == D2_1444_RECEIVER
		and str(replacement.get("roof_object_key", "")) == "building:w95934117:roof"
		and _int_array_matches(replacement.get("mapped_public_run_indices", []) as Array, [8, 9, 11, 12, 15, 16, 17])
		and _int_array_matches(replacement.get("protected_run_indices", []) as Array, [0, 1, 2, 3, 4, 5, 6, 7, 10, 13, 14, 18, 19, 20, 21])
		and bool(replacement.get("actual_supplied_chunk_pair_required", false))
		and replacement.get("fallback_allowed") == false
		and replacement.get("generic_stack_allowed") == false
		and replacement.get("partial_pair_allowed") == false
		and truth.get("as_built_fidelity_claimed") == false
		and truth.get("capture_time_candidate_promoted") == false
		and truth.get("capture_time_recognition_credit") == false
		and truth.get("game_distinctive_claimed") == false
		and truth.get("reference_pixels_packaged") == false
		and truth.get("receiver_complete_inferred_from_art") == false
		and bool(truth.get("unsurveyed_opening_roof_void_rail_dimensions_and_counts_are_production_inference", false))
		and bool(truth.get("unobserved_sides_protected", false)),
		"d2_1444_parity_mismatch",
		"D2 1444 frozen capture-time evidence, paired topology, ownership, replacement, or truth boundary drifted.",
	)


func _validate_d2_1439_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d2_1439_chinook_quality_v2_live_replacement.gd", D2_1439_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d2_1439_chinook_quality_v2_prototype.gd", D2_1439_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D2_1439_SITE_KIT_SHA256),
		"d2_1439_parity_mismatch",
		"D2 1439 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)


func _validate_d2_1444_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d2_1444_croaker_quality_v2_live_replacement.gd", D2_1444_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d2_1444_croaker_quality_v2_prototype.gd", D2_1444_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D2_1444_SITE_KIT_SHA256),
		"d2_1444_parity_mismatch",
		"D2 1444 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)


func _validate_d5_1394_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "d5_1394_parity_mismatch", "D5 1394 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == D5_1394_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215646"
		and str(adapter.get("receiver_key", "")) == D5_1394_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_d5_1394_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_d5_1394_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"d5_1394_parity_mismatch",
		"D5 1394 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 24,
		"d5_1394_parity_mismatch",
		"D5 1394 active receiver scope does not cover the exact 24-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := D5_1394_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "d5_1394_parity_mismatch", "D5 1394 active adapter does not contain its exact 7-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"d5_1394_parity_mismatch",
		"D5 1394 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == D5_1394_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == D5_1394_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == D5_1394_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == D5_1394_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == D5_1394_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == D5_1394_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d5_1394_gateview_live_replacement.gd", D5_1394_ADAPTER_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1394_gateview_live_replacement.json", D5_1394_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d5_1394_gateview_live_factory.gd", D5_1394_PROTOTYPE_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1394_gateview_live_factory.json", D5_1394_PROTOTYPE_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D5_1394_SITE_KIT_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1394_siding_marks.gdshader", "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e")
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1394_lawn_tone.gdshader", "d60b1db292234046d2e8fd1a451e0f3f52a69b12afe401e871bedef6067ca7af"),
		"d5_1394_parity_mismatch",
		"D5 1394 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _validate_d5_1394_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_d5_1394_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.d5-1394-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "ec327adb9239a902f40fd7e2ede7afedcd19bf1869b392e9646544721eaec316"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "0ad7ff068f42b8230ba724d9143c9c563130de3c9d40c37837f1ed21f95ecc60"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "6a057c2b0236e90d11861499c299b723b35da37ee3590a0a154d0c3390f0b2cb"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "9be91b038dc142ac84d3947ed68733c2346aa5756e4ccbb433bf0a173b8ca364"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "464224831dfadcc4657fdb3575fc47501190ad41c44163a7dd05885284772689"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "c2c4ee90347b458e44fda87d900a4a2031b2cf4883c16a0db1ceac0ffeec02cd"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "c7b5079a3a59847b80e201ef8107928381f9370dd74001f2675f0c68de82dbc8"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215646"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "13/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 0.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215646"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215646:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215646:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == true
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [1, 2, 3, 4, 15, 16, 17, 18, 20, 21, 22, 23])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 19])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_geometry_sha256", "canonical_wall_record_sha256", "canonical_roof_record_sha256", "canonical_terrain_records", "horizontal_source_footprint_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope", "capture_isolated_world_mesh_instances", "capture_isolated_world_surfaces", "capture_isolated_world_triangles", "capture_isolated_world_shapes"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256") == "b0e6c7426ac41c995f96a647ff5102b4d85963d2b7a45f21ad1b81455e451220"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256") == "222fc29f2d1526d983f4653dc8ae157aa98575dbbfb16c89898827a26dc26019"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256") == "299f27cd69cc90668bdd31cb076d083ee1bf98e28b0031cdbe4e38bfd0c2cc51"
		and _has_exact_keys(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary), ["area:r17241151:x_-2__z_-3", "land:w26767313:x_-2__z_-3"])
		and typeof(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("area:r17241151:x_-2__z_-3")) == TYPE_STRING and ((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("area:r17241151:x_-2__z_-3") == "462c4532716ddaa63c66d0c11300771ee7eb1089c27565037fb2e148b85c5d7c"
		and typeof(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("land:w26767313:x_-2__z_-3")) == TYPE_STRING and ((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("land:w26767313:x_-2__z_-3") == "17c60f0f623bf919bd05c0ebc4ae93c06cce0c33a5603725175f3c4754572c02"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 16.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 16.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 3368.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1006.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1021.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 79913.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 466.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 474.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "pre_d5_1317_integration_quality_batch_topology"
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_mesh_instances")) == 997.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_surfaces")) == 1012.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_triangles")) == 77604.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_shapes")) == 472.0
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "eligible_exterior_collision_triangles", "noneligible_canopy_post_collision_triangles", "noneligible_ground_collision_triangles", "wall_collision_triangles", "roof_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 4.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 3
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "eligible_exterior"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "noneligible_canopy_posts"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "noneligible_closed_modules"
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) == 48.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_canopy_post_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_canopy_post_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_canopy_post_collision_triangles")) == 204.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_ground_collision_triangles")) == 2016.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) == 2268.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) == 16.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "direct_continuous_outgoing_land_contact_ownership_claimed"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("direct_continuous_outgoing_land_contact_ownership_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("direct_continuous_outgoing_land_contact_ownership_claimed") == false,
		"d5_1394_parity_mismatch",
		"D5 1394 exact quality acceptance, paired source, terrain, shape ownership or historical/current scope drifted.",
	)


func _validate_d5_1394_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d5_1394_gateview_live_replacement.gd", D5_1394_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d5_1394_gateview_live_factory.gd", D5_1394_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D5_1394_SITE_KIT_SHA256),
		"d5_1394_parity_mismatch",
		"D5 1394 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)


func _validate_d5_1317_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "d5_1317_parity_mismatch", "D5 1317 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == D5_1317_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w95934125"
		and str(adapter.get("receiver_key", "")) == D5_1317_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_d5_1317_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_d5_1317_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"d5_1317_parity_mismatch",
		"D5 1317 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 34,
		"d5_1317_parity_mismatch",
		"D5 1317 active receiver scope does not cover the exact 34-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := D5_1317_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "d5_1317_parity_mismatch", "D5 1317 active adapter does not contain its exact 8-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"d5_1317_parity_mismatch",
		"D5 1317 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == D5_1317_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == D5_1317_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == D5_1317_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == D5_1317_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == D5_1317_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == D5_1317_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d5_1317_gateview_live_replacement.gd", D5_1317_ADAPTER_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1317_gateview_live_replacement.json", D5_1317_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d5_1317_gateview_live_factory.gd", D5_1317_PROTOTYPE_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1317_gateview_quality_study.json", D5_1317_PROTOTYPE_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D5_1317_SITE_KIT_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1317_siding_marks.gdshader", "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e")
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1317_quality_study_geometry.json", "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9")
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1317_surface_tone.gdshader", "2388fbee5821352c30ec5925f4ff159439090c8cb1f4973344a947c65b4e4da0"),
		"d5_1317_parity_mismatch",
		"D5 1317 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _validate_d5_1317_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_d5_1317_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.d5-1317-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "4fcdd7f900dfadb12187f558bf0e545038d8386134ed1e7f9830810be763ddb5"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "a1e3d98ebacaf73c5fb985a2fa2ee4597fe4c2b334cc102c3d3ea460bf361214"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "088c0a0df84440cf2ddb35996aabc5d1b1aa5e1fcafe47217cd92dbbca08fc15"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "d6041941c9ec59d6a6d8fac4cbb79964fe842cdc135baf5c7a36df3a65a2c98e"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "18da75ad3394e86f3129449bbf113efd14d2e845acd767acba995545b3e5f6ee"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "7cd3ef79e13c19bbb34b601338f86533b9de429d274d35e55e8e6f8fbd8afdce"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "19edda17a50fd957ec09bd9a2ea310b7f82524e717c63467d5198e2e3f9500df"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w95934125"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "13/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w95934125"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w95934125:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w95934125:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == true
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [10, 13, 14, 15, 17, 20, 22, 24, 26, 27, 29, 31])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 16, 18, 19, 21, 23, 25, 28, 30, 32, 33])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_geometry_sha256", "canonical_wall_record_sha256", "canonical_roof_record_sha256", "canonical_terrain_records", "horizontal_source_footprint_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope", "capture_isolated_world_mesh_instances", "capture_isolated_world_surfaces", "capture_isolated_world_triangles", "capture_isolated_world_shapes"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256") == "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256") == "3537997ae045f8022bbe4c6449cec82655797411e417397d15ace85fedc3a6ef"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256") == "ae444960fc7ae2d8cae3a7fa28637ecd06b9c17d691d3c69c146564d5c6874ef"
		and _has_exact_keys(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary), ["area:r17241151:x_-3__z_-2", "area:r17241152:x_-3__z_-2", "land:w26767313:x_-3__z_-2"])
		and typeof(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("area:r17241151:x_-3__z_-2")) == TYPE_STRING and ((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("area:r17241151:x_-3__z_-2") == "336bb7c5d763d853c19184da045cf4a114f25493ecf02a367ca1e0523d8bebd1"
		and typeof(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("area:r17241152:x_-3__z_-2")) == TYPE_STRING and ((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("area:r17241152:x_-3__z_-2") == "104faf44f5234729b0411e75595abeec1888f867d0efa6a3d765aaa4f93d991e"
		and typeof(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("land:w26767313:x_-3__z_-2")) == TYPE_STRING and ((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("land:w26767313:x_-3__z_-2") == "9ff2ddf4241136939a8dbe377679ef9f30e4c17e229b91ffbafc117c03d47c04"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 1938.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1018.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1033.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 81761.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 466.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 477.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "pre_station48_integration_live_parity"
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_mesh_instances")) == 1005.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_surfaces")) == 1020.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_triangles")) == 78224.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_shapes")) == 475.0
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "wall_shape_collision_triangles", "roof_shape_order", "roof_shape_collision_triangles", "eligible_exterior_collision_triangles", "noneligible_canopy_post_collision_triangles", "noneligible_closed_lower_collision_triangles", "wall_collision_triangles", "roof_collision_triangles", "visual_ground_triangles", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 5.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 3
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "noneligible_canopies_posts_braces"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "noneligible_closed_lower_modules"
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("wall_shape_collision_triangles") as Array), [68, 192, 648])
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 2
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_source_roof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1] == "added_public_roof"
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("roof_shape_collision_triangles") as Array), [22, 108])
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) == 68.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_canopy_post_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_canopy_post_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_canopy_post_collision_triangles")) == 192.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_closed_lower_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_closed_lower_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_closed_lower_collision_triangles")) == 648.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) == 908.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) == 130.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("visual_ground_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("visual_ground_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("visual_ground_triangles")) == 36.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "direct_continuous_outgoing_land_contact_ownership_claimed", "continuous_motion_review_claimed"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("direct_continuous_outgoing_land_contact_ownership_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("direct_continuous_outgoing_land_contact_ownership_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false,
		"d5_1317_parity_mismatch",
		"D5 1317 exact new-unit acceptance, source, collision ownership or capture/current scope drifted.",
	)


func _validate_d5_1317_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d5_1317_gateview_live_replacement.gd", D5_1317_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d5_1317_gateview_live_factory.gd", D5_1317_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D5_1317_SITE_KIT_SHA256),
		"d5_1317_parity_mismatch",
		"D5 1317 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)


func _validate_fire_station48_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "fire_station48_parity_mismatch", "Station48 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == FIRE_STATION48_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w764313741"
		and str(adapter.get("receiver_key", "")) == FIRE_STATION48_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_fire_station48_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_fire_station48_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"fire_station48_parity_mismatch",
		"Station48 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 26,
		"fire_station48_parity_mismatch",
		"Station48 active receiver scope does not cover the exact 26-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := FIRE_STATION48_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "fire_station48_parity_mismatch", "Station48 active adapter does not contain its exact 7-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"fire_station48_parity_mismatch",
		"Station48 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == FIRE_STATION48_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == FIRE_STATION48_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == FIRE_STATION48_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == FIRE_STATION48_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == FIRE_STATION48_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == FIRE_STATION48_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/fire_station48_live_replacement.gd", "163db6f19bb7368f5aa271282c11d4028337d48cc1b2e3d37b8231e1c329d25a")
		and _runtime_asset_match(assets, "res://game/resources/facades/fire_station48_live_replacement.json", "4b31025a80909b03b882c089bf17d50dbc6a4ee9d32fa9b072b884fd4eec061a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/fire_station48_live_factory.gd", "33c945be3699fe7f94874d7a65ff0d01963092d0c0cb85deacaf4f794d9996d5")
		and _runtime_asset_match(assets, "res://game/resources/facades/fire_station48_quality_study.json", "2ae853642ed360f81ea6dfe53089fa909531af8776f40462fb129076f16b6795")
		and _runtime_asset_match(assets, "res://game/resources/facades/fire_station48_upper_cladding.gdshader", "4600d14f6d45455c56ce400cc2b073c124462eee1da0e33f7492b356614f319e")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd")
		and _runtime_asset_match(assets, "res://game/resources/facades/fire_station48_study_geometry.json", "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597"),
		"fire_station48_parity_mismatch",
		"Station48 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _validate_fire_station48_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_fire_station48_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.fire-station48-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "f68b77fa5c6e8983288ad9f9ca36a4fd827e716cc1c99877270eeceb547786b6"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "4e3a0ea032384bc1381468db84ae15c4ebc1eb75212a9fec20156d165414b028"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "708692fe592b56c9b18cbf5d9bbc086dadb1c053153d37afbd5c37c6a91c0a3e"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "502c87a102c90ef446a1e3415b1bb6eca7050d46689c550c18609c3c9dc43b0b"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "6e8e1a6d8ff3ee12e961d7adaa78cdc72e8aa57dbb607251d5a1361c171eb895"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "fb4802671d8ec92d2cdff091a221fc6fe8f3d1dae6780446aa5604227f7cfed4"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "cb06367c7de02d2379c855dfe33915d8bd54b85a33666f0582e949752f9310cf"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w764313741"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "14/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w764313741"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w764313741:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w764313741:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [0, 1, 2, 3, 5, 6, 8, 9, 24, 25])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [4, 7, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_geometry_sha256", "canonical_wall_record_sha256", "canonical_roof_record_sha256", "source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256") == "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256") == "0e3b5283ff9c055dc0a642d3608af13057ed6d1c87293d4b845991d9e96f9a8d"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256") == "a64186052e8331d3ee744718f19ba8dc6350da4f67c8b51f29b9469c903c89d2"
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 7.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 7.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 1090.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1023.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1038.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 82789.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 466.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 477.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "pre_maceo_may_integration_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "wall_shape_collision_triangles", "roof_shape_order", "roof_shape_collision_triangles", "eligible_exterior_collision_triangles", "wall_collision_triangles", "roof_collision_triangles", "added_collision_triangles", "all_additions_render_only", "visual_ground_triangles", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("wall_shape_collision_triangles") as Array), [52])
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("roof_shape_collision_triangles") as Array), [10])
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) == 52.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) == 52.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) == 10.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("visual_ground_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("visual_ground_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("visual_ground_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "roof_support_setup_is_separate", "spray_input_event_dispatch_claimed"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("roof_support_setup_is_separate")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("roof_support_setup_is_separate") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false,
		"fire_station48_parity_mismatch",
		"Station48 exact unit acceptance, source-only collision, render-only additions or historical capture scope drifted.",
	)


func _validate_fire_station48_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/fire_station48_live_replacement.gd", FIRE_STATION48_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/fire_station48_live_factory.gd", FIRE_STATION48_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", FIRE_STATION48_SITE_KIT_SHA256),
		"fire_station48_parity_mismatch",
		"Station48 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)


func _validate_maceo_may_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "maceo_may_parity_mismatch", "Maceo May exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == MACEO_MAY_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "r19685981"
		and str(adapter.get("receiver_key", "")) == MACEO_MAY_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_maceo_may_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_maceo_may_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"maceo_may_parity_mismatch",
		"Maceo May active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 40,
		"maceo_may_parity_mismatch",
		"Maceo May active receiver scope does not cover the exact 40-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := MACEO_MAY_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "maceo_may_parity_mismatch", "Maceo May active adapter does not contain its exact 7-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"maceo_may_parity_mismatch",
		"Maceo May active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == MACEO_MAY_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == MACEO_MAY_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == MACEO_MAY_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == MACEO_MAY_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == MACEO_MAY_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == MACEO_MAY_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/maceo_may_live_replacement.gd", "d9ad456c2d11437a0cf70277c7fab383359c49d6ab34ed698ec316ea97668001")
		and _runtime_asset_match(assets, "res://game/resources/facades/maceo_may_live_replacement.json", "cf97a1197fdc2c5cea8f5befddcb6f6f75306d9a2b969a6e3297efad0b319c6c")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/maceo_may_live_factory.gd", "bb47a10d3464f162516ece9ac0591bdead1791e847b89eff35fd3f59adc56c85")
		and _runtime_asset_match(assets, "res://game/resources/facades/maceo_may_quality_study.json", "11a8784bbb08ea4a6244b1da1dcc8e0c2b589ef66c55a0bd2cc8ff20ad16cd6d")
		and _runtime_asset_match(assets, "res://game/resources/facades/maceo_may_public_fields.gdshader", "04169ff9212cf35fb50d53dc18791600c5c7647618d8e6c58021bbbc3c724279")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd")
		and _runtime_asset_match(assets, "res://game/resources/facades/maceo_may_study_geometry.json", "4caf46d6c3ebb1ef497fbe8012e5f1fd938a055e11a4132c04ed8e6827da12b3"),
		"maceo_may_parity_mismatch",
		"Maceo May adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _validate_maceo_may_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_maceo_may_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.maceo-may-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "82543ad09bc51281499280965d9bc949ecc99781d80520801742bd3643404862"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "83a8637cd539efa3899b8d97147a82a02d976aa8baed4209824e2724a2ac7e2b"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "3c7c3e933062d4cf3994f47cb48a62c41b7c1cf42fa41693ff82474cec1db86d"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "e903e64348aa003ca957b1e1efebc57a516395134f40d56e1ba1c5ebc3ad877f"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "916457b92cee4b002cab5c47b6ecd29a8c8d398a9ad685c05e7bc8f5d9874e0a"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "749cd826a0ea791b696ab98464e5c19548f14d45734d88111a79376a74dd5c8c"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "e08d71c45bfc67e05ab2fd2a8d4e8362ef7692f96d5817d60856a251b473b14e"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:r19685981"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "14/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "r19685981"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:r19685981:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:r19685981:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [8, 9, 10, 11, 12, 13, 14, 15, 16])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_geometry_sha256", "canonical_wall_record_sha256", "canonical_roof_record_sha256", "source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256") == "4caf46d6c3ebb1ef497fbe8012e5f1fd938a055e11a4132c04ed8e6827da12b3"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256") == "c68403647a2a1f39a1957813e44c161882c88911d8f0eae574f7f9806ae07b44"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256") == "86a5ea5b74ab4713f75ff1c6c35cf5132b70c7e33c228f988983c6c7303139cc"
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 11.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 11.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 16436.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1032.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1047.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 99129.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 466.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 478.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "pre_northern_batch_integration_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "wall_shape_collision_triangles", "roof_shape_order", "roof_shape_collision_triangles", "eligible_exterior_collision_triangles", "wall_collision_triangles", "roof_collision_triangles", "added_collision_triangles", "all_additions_render_only", "visual_ground_triangles", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 3.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 2
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "noneligible_entrance_columns"
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("wall_shape_collision_triangles") as Array), [80, 320])
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("roof_shape_collision_triangles") as Array), [16])
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) == 80.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) == 400.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) == 16.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_collision_triangles")) == 320.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("visual_ground_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("visual_ground_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("visual_ground_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "roof_support_setup_is_separate", "spray_input_event_dispatch_claimed"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("roof_support_setup_is_separate")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("roof_support_setup_is_separate") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false,
		"maceo_may_parity_mismatch",
		"Maceo May exact acceptance, source wall/roof, separate nonreceiver columns or historical capture scope drifted.",
	)


func _validate_maceo_may_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/maceo_may_live_replacement.gd", MACEO_MAY_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/maceo_may_live_factory.gd", MACEO_MAY_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", MACEO_MAY_SITE_KIT_SHA256),
		"maceo_may_parity_mismatch",
		"Maceo May executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)


func _validate_d5_1308_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "d5_1308_parity_mismatch", "D5 1308 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == D5_1308_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w95934123"
		and str(adapter.get("receiver_key", "")) == D5_1308_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_d5_1308_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_d5_1308_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"d5_1308_parity_mismatch",
		"D5 1308 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 34,
		"d5_1308_parity_mismatch",
		"D5 1308 active receiver scope does not cover the exact 34-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := D5_1308_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "d5_1308_parity_mismatch", "D5 1308 active adapter does not contain its exact 7-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"d5_1308_parity_mismatch",
		"D5 1308 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == D5_1308_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == D5_1308_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == D5_1308_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == D5_1308_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == D5_1308_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == D5_1308_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d5_1308_gateview_live_replacement.gd", D5_1308_ADAPTER_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1308_gateview_live_replacement.json", D5_1308_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/d5_1308_gateview_live_factory.gd", D5_1308_PROTOTYPE_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1308_gateview_live_factory.json", D5_1308_PROTOTYPE_CONFIG_SHA256)
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D5_1308_SITE_KIT_SHA256)
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1308_siding_marks.gdshader", "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e")
		and _runtime_asset_match(assets, "res://game/resources/facades/d5_1308_lawn_tone.gdshader", "d60b1db292234046d2e8fd1a451e0f3f52a69b12afe401e871bedef6067ca7af"),
		"d5_1308_parity_mismatch",
		"D5 1308 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _validate_d5_1308_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_d5_1308_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.d5-1308-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "7c01ff32b1da4276ec330aee0d034dce4f0cbe8caa510f96d99504084cb314b5"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "f139576c7b45eb76774315745504992f6bd726cd698faab6b88e79f491197960"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "f0d21bb4dc14d8a12aba1fc37614e3cced7ff331521dda06a802bfc6fbd69dc9"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "c892d30b9c06f280077712c2bbad710eefac67f9fa1dd4b1f92c8f07c0b329dc"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "e17f311ea69445d8da9b4029e9d4d93fba19ea2cd2901efa2e2ec1d7dd90556a"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "9c094ed7a52506404a6763298504b71706b75ade1f44e4cfe2ad3fb6ea81380f"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "87a2af8c5ab11082337265f53ca5fcd3aa9f0dbfdd22f97e7a8968653ad71a06"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w95934123"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "13/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 0.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w95934123"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w95934123:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w95934123:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == true
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [0, 1, 2, 3, 5, 7, 8, 9, 10, 11, 12, 13, 14, 17, 18, 19, 20, 21, 27, 32])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [4, 6, 15, 16, 22, 23, 24, 25, 26, 28, 29, 30, 31, 33])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_geometry_sha256", "canonical_wall_record_sha256", "canonical_roof_record_sha256", "canonical_terrain_records", "horizontal_source_footprint_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope", "capture_isolated_world_mesh_instances", "capture_isolated_world_surfaces", "capture_isolated_world_triangles", "capture_isolated_world_shapes"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_geometry_sha256") == "6028c89be31ebfd095777b86f6d5d4a9094002b7b5fd73efb2fc940f9a9f3917"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_wall_record_sha256") == "5bf75fcc75fdbc83d45a97a6a4168a439e8c31bcbc473105147f831a09458abd"
		and typeof((contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("canonical_roof_record_sha256") == "34d0a95387fc6f17a889aac602ce5e630a67b4d0d9f8b5fb6264291d674b7b00"
		and _has_exact_keys(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary), ["area:r17241151:x_-2__z_-1", "land:w26767313:x_-2__z_-1"])
		and typeof(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("area:r17241151:x_-2__z_-1")) == TYPE_STRING and ((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("area:r17241151:x_-2__z_-1") == "0c1ca3e7d64c4fe9c5d561a00832651fa634b7a0c3bfae9f8434fa9526c58e53"
		and typeof(((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("land:w26767313:x_-2__z_-1")) == TYPE_STRING and ((contract.get("geometry_contract") as Dictionary).get("canonical_terrain_records") as Dictionary).get("land:w26767313:x_-2__z_-1") == "5508f75d3cc82559353123a3af167a0bb5b375eea73b84537d38a82b595579f7"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 17.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 17.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 4871.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1006.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1021.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 79913.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 466.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 474.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "same_batch_combined_topology_reference"
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_mesh_instances")) == 1002.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_surfaces")) == 1017.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_triangles")) == 78685.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("capture_isolated_world_shapes")) == 474.0
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "eligible_exterior_collision_triangles", "noneligible_canopy_post_collision_triangles", "noneligible_ground_collision_triangles", "wall_collision_triangles", "roof_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged", "noneligible_closed_lower_collision_triangles", "roof_shape_order", "roof_shape_collision_triangles"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 6.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 4
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "eligible_exterior"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "noneligible_canopy_posts"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "noneligible_grade_pads"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "noneligible_closed_lower"
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_exterior_collision_triangles")) == 68.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_canopy_post_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_canopy_post_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_canopy_post_collision_triangles")) == 240.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_ground_collision_triangles")) == 96.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_collision_triangles")) == 1196.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("roof_collision_triangles")) == 1402.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_closed_lower_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_closed_lower_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_closed_lower_collision_triangles")) == 792.0
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 2
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_source_roof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1] == "added_public_roof"
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("roof_shape_collision_triangles") as Array), [22, 1380])
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "direct_continuous_outgoing_land_contact_ownership_claimed"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("direct_continuous_outgoing_land_contact_ownership_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("direct_continuous_outgoing_land_contact_ownership_claimed") == false,
		"d5_1308_parity_mismatch",
		"D5 1308 exact quality acceptance, paired source, terrain, shape ownership or historical/current scope drifted.",
	)


func _validate_d5_1308_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d5_1308_gateview_live_replacement.gd", D5_1308_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/d5_1308_gateview_live_factory.gd", D5_1308_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", D5_1308_SITE_KIT_SHA256),
		"d5_1308_parity_mismatch",
		"D5 1308 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)


func _validate_current_topology_authority(active_adapters: Array) -> bool:
	var current_topology_adapter_ids := []
	for adapter_value: Variant in active_adapters:
		var adapter := adapter_value as Dictionary
		var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
		var behavior_contract_value: Variant = runtime_contract.get("behavior_contract", {})
		var behavior_contract := behavior_contract_value as Dictionary if behavior_contract_value is Dictionary else {}
		var geometry_contract := behavior_contract.get("geometry_contract", {}) as Dictionary
		if str(geometry_contract.get("world_topology_scope", "")) == CURRENT_INTEGRATION_WORLD_TOPOLOGY_SCOPE:
			current_topology_adapter_ids.append(str(adapter.get("adapter_id", "")))
	return _require(
		current_topology_adapter_ids == [NORTHERN_1202_ADAPTER_ID],
		"current_topology_authority_mismatch",
		"Exactly the final serialized 1202 adapter must own the measured combined integration topology; prior evidence scopes must remain historical.",
	)


func _validate_runtime_asset(asset: Dictionary, owner_id: String) -> bool:
	if not _require(_has_exact_keys(asset, ["path", "sha256"]), "runtime_asset_invalid", "%s runtime asset fields drifted." % owner_id):
		return false
	var path := str(asset.get("path", ""))
	if not _require(_is_safe_runtime_path(path), "dirty_path", "%s runtime asset escapes the game package: %s" % [owner_id, path]):
		return false
	if not _require(FileAccess.file_exists(path), "runtime_asset_missing", "%s runtime asset is missing: %s" % [owner_id, path]):
		return false
	if not _require(_is_sha256(str(asset.get("sha256", ""))) and _measured_file_sha256(path) == str(asset.get("sha256", "")), "runtime_asset_hash_drift", "%s runtime asset hash drifted: %s" % [owner_id, path]):
		return false
	return _runtime_asset_closure_is_clean(path, {})


func _runtime_asset_closure_is_clean(path: String, visited: Dictionary) -> bool:
	if visited.has(path):
		return true
	visited[path] = true
	if not FileAccess.file_exists(path):
		return _require(false, "runtime_asset_missing", "Runtime dependency is missing: %s" % path)
	if not TEXT_ASSET_EXTENSIONS.has(path.get_extension().to_lower()):
		return true
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _require(false, "runtime_asset_missing", "Runtime dependency cannot be opened: %s" % path)
	var read_started_usec: int = Time.get_ticks_usec() if _measurement_enabled else 0
	var contents := file.get_as_text()
	if _measurement_enabled:
		_measurement.closure_read_calls += 1
		_measurement.closure_read_bytes += file.get_length()
		_measurement.closure_read_usec += Time.get_ticks_usec() - read_started_usec
	if not _runtime_asset_text_is_clean(contents):
		return _require(false, "dirty_asset_closure", "Runtime dependency closure contains a source-only path or URL: %s" % path)
	if path in ["res://game/scripts/world/facades/northern_canopy_free_live_replacement.gd", "res://game/scripts/world/facades/mariner_1206_live_replacement.gd", "res://game/scripts/world/facades/mariner_1219_live_replacement.gd", "res://game/scripts/world/facades/mariner_1212_live_replacement.gd", "res://game/scripts/world/facades/bayside_1220_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1239_live_replacement.gd", "res://game/scripts/world/facades/bayside_1222_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1227_live_replacement.gd", "res://game/scripts/world/facades/mariner_1202_live_replacement.gd", "res://game/scripts/world/facades/northpoint_1238_live_replacement.gd"]:
		var expected_hash: String = NORTHERN_1202_ADAPTER_SHA256 if path.ends_with("/mariner_1202_live_replacement.gd") else NORTHERN_1227_ADAPTER_SHA256 if path.ends_with("/northpoint_1227_live_replacement.gd") else NORTHERN_1222_ADAPTER_SHA256 if path.ends_with("/bayside_1222_live_replacement.gd") else NORTHERN_1239_ADAPTER_SHA256 if path.ends_with("/northpoint_1239_live_replacement.gd") else NORTHERN_1220_ADAPTER_SHA256 if path.ends_with("/bayside_1220_live_replacement.gd") else NORTHERN_1212_ADAPTER_SHA256 if path.ends_with("/mariner_1212_live_replacement.gd") else NORTHERN_1219_ADAPTER_SHA256 if path.ends_with("/mariner_1219_live_replacement.gd") else NORTHERN_1206_ADAPTER_SHA256 if path.ends_with("/mariner_1206_live_replacement.gd") else NORTHERN_1201_ADAPTER_SHA256 if path.ends_with("/northern_canopy_free_live_replacement.gd") else NORTHERN_1238_ADAPTER_SHA256
		if not _require(contents.sha256_text() == expected_hash, "runtime_asset_hash_drift", "Northern format-probe wrapper source drifted."):
			return false
		for probe_name: String in ["project.binary", "project.godot"]:
			var probe: String = 'FileAccess.file_exists("res' + '://' + probe_name + '")'
			if not _require(contents.count(probe) == 1, "runtime_asset_invalid", "Northern exact format-probe expression drifted."):
				return false
			contents = contents.replace(probe, "true")
	var cursor := 0
	while true:
		var dependency_start := contents.find("res://", cursor)
		if dependency_start < 0:
			break
		var dependency_end := contents.find("\"", dependency_start)
		if dependency_end < 0:
			return _require(false, "runtime_asset_invalid", "Runtime dependency path is unterminated in %s." % path)
		var dependency_path := contents.substr(dependency_start, dependency_end - dependency_start)
		if dependency_path.ends_with("/"):
			cursor = dependency_end + 1
			continue
		if not _is_safe_runtime_dependency_path(dependency_path):
			return _require(false, "dirty_asset_closure", "Runtime dependency escapes the game package: %s" % dependency_path)
		if not _runtime_asset_closure_is_clean(dependency_path, visited):
			return false
		cursor = dependency_end + 1
	return true


func _runtime_asset_match(assets: Array, path: String, sha256: String) -> bool:
	for asset_value: Variant in assets:
		var asset := asset_value as Dictionary
		if str(asset.get("path", "")) == path and str(asset.get("sha256", "")) == sha256:
			return true
	return false


func _runtime_asset_arrays_match(left: Array, right: Array) -> bool:
	var left_signatures := []
	var right_signatures := []
	for asset_value: Variant in left:
		var asset := asset_value as Dictionary
		left_signatures.append("%s:%s" % [str(asset.get("path", "")), str(asset.get("sha256", ""))])
	for asset_value: Variant in right:
		var asset := asset_value as Dictionary
		right_signatures.append("%s:%s" % [str(asset.get("path", "")), str(asset.get("sha256", ""))])
	left_signatures.sort()
	right_signatures.sort()
	return left_signatures == right_signatures


func _projection_descriptor_ids_for_adapter(adapter: Dictionary) -> Array:
	var descriptor_ids := []
	for projection_value: Variant in adapter.get("runtime_asset_projections", []) as Array:
		var projection := projection_value as Dictionary
		var matched_id := ""
		for descriptor_value: Variant in _projections_by_id.values():
			var descriptor := descriptor_value as Dictionary
			if str(descriptor.get("source_asset_sha256", "")) == str(projection.get("source_asset_sha256", "")) \
			and str(descriptor.get("source_asset_type", "")) == str(projection.get("source_asset_type", "")):
				matched_id = str(descriptor.get("descriptor_id", ""))
				break
		if matched_id.is_empty():
			return ["__missing_projection_descriptor__"]
		if not descriptor_ids.has(matched_id):
			descriptor_ids.append(matched_id)
	return descriptor_ids


func _registry_projection_occurrence_matches(occurrence_id: String, descriptor: Dictionary) -> bool:
	for adapter_value: Variant in _adapters_by_id.values():
		var adapter := adapter_value as Dictionary
		for projection_value: Variant in adapter.get("runtime_asset_projections", []) as Array:
			var projection := projection_value as Dictionary
			if str(projection.get("projection_id", "")) != occurrence_id:
				continue
			return str(projection.get("source_asset_sha256", "")) == str(descriptor.get("source_asset_sha256", "")) \
				and str(projection.get("source_asset_type", "")) == str(descriptor.get("source_asset_type", "")) \
				and (descriptor.get("consumer_adapter_ids", []) as Array).has(str(adapter.get("adapter_id", "")))
	return false


func _array_is_unique(values: Array) -> bool:
	var seen := {}
	for value: Variant in values:
		var key := str(value)
		if seen.has(key):
			return false
		seen[key] = true
	return true


func _int_array_matches(values: Array, expected: Array) -> bool:
	if values.size() != expected.size():
		return false
	for index in expected.size():
		var value_type := typeof(values[index])
		if value_type != TYPE_INT and value_type != TYPE_FLOAT:
			return false
		var numeric_value := float(values[index])
		if not is_finite(numeric_value) or numeric_value != floor(numeric_value) or numeric_value != float(expected[index]):
			return false
	return true


func _derive_unit_content_mode(receivers: Array) -> String:
	var modes := {}
	for receiver_value: Variant in receivers:
		modes[str((receiver_value as Dictionary).get("runtime_content_mode", ""))] = true
	var values := modes.keys()
	values.sort()
	if values == ["generated_placeholder"]:
		return "all_receivers_generated_placeholder"
	if values == ["legacy_adapter"]:
		return "all_receivers_legacy_adapter"
	if values == ["active_building_1_hero"]:
		return "all_receivers_active_building_1_hero"
	if values == ["active_building_3_hero"]:
		return "all_receivers_active_building_3_hero"
	if values == ["active_isle_house_variant_c"]:
		return "all_receivers_active_isle_house_variant_c"
	if values == ["active_navy_chapel_187_paired_replacement"]:
		return "all_receivers_active_navy_chapel_187_paired_replacement"
	if values == ["active_d1_b201_host_partition_attachment"]:
		return "all_receivers_active_d1_b201_host_partition_attachment"
	if values == ["active_d1_b225_host_partition_attachment"]:
		return "all_receivers_active_d1_b225_host_partition_attachment"
	if values == ["active_d2_1441_paired_replacement"]:
		return "all_receivers_active_d2_1441_paired_replacement"
	if values == ["active_d2_1439_paired_replacement"]:
		return "all_receivers_active_d2_1439_paired_replacement"
	if values == ["active_d2_1444_paired_replacement"]:
		return "all_receivers_active_d2_1444_paired_replacement"
	if values == ["active_d5_1394_paired_replacement"]:
		return "all_receivers_active_d5_1394_paired_replacement"
	if values == ["active_d5_1317_paired_replacement"]:
		return "all_receivers_active_d5_1317_paired_replacement"
	if values == ["active_fire_station48_paired_replacement"]:
		return "all_receivers_active_fire_station48_paired_replacement"
	if values == ["active_maceo_may_paired_replacement"]:
		return "all_receivers_active_maceo_may_paired_replacement"
	if values == ["active_northern_1202_paired_replacement"]:
		return "all_receivers_active_northern_1202_paired_replacement"
	if values == ["active_northern_1227_paired_replacement"]:
		return "all_receivers_active_northern_1227_paired_replacement"
	if values == ["active_northern_1222_paired_replacement"]:
		return "all_receivers_active_northern_1222_paired_replacement"
	if values == ["active_northern_1239_paired_replacement"]:
		return "all_receivers_active_northern_1239_paired_replacement"
	if values == ["active_northern_1220_paired_replacement"]:
		return "all_receivers_active_northern_1220_paired_replacement"
	if values == ["active_northern_1212_paired_replacement"]:
		return "all_receivers_active_northern_1212_paired_replacement"
	if values == ["active_northern_1219_paired_replacement"]:
		return "all_receivers_active_northern_1219_paired_replacement"
	if values == ["active_northern_1206_paired_replacement"]:
		return "all_receivers_active_northern_1206_paired_replacement"
	if values == ["active_northern_1238_paired_replacement"]:
		return "all_receivers_active_northern_1238_paired_replacement"
	if values == ["active_northern_1201_paired_replacement"]:
		return "all_receivers_active_northern_1201_paired_replacement"
	if values == ["active_d5_1308_paired_replacement"]:
		return "all_receivers_active_d5_1308_paired_replacement"
	if values == ["generated_placeholder", "legacy_adapter"]:
		return "mixed_legacy_adapter_and_generated_placeholder"
	if values == ["active_isle_house_variant_c", "legacy_adapter"]:
		return "mixed_legacy_high_and_active_variant_c_low"
	return "mixed_runtime_content"


func _receiver_by_key(receivers: Array, receiver_key: String) -> Dictionary:
	for receiver_value: Variant in receivers:
		var receiver := receiver_value as Dictionary
		if str(receiver.get("receiver_key", "")) == receiver_key:
			return receiver
	return {}


func _is_allowed_executable(path: String, kind: String) -> bool:
	if not ALLOWED_EXECUTABLE_KINDS.has(kind) or not _is_safe_runtime_path(path):
		return false
	if not ALLOWED_EXECUTABLE_ROOTS.any(func(root: Variant) -> bool: return path.begins_with(str(root))):
		return false
	return (kind == "gdscript" and path.ends_with(".gd")) or (kind == "packed_scene" and path.ends_with(".tscn"))


func _is_safe_runtime_json_path(path: String) -> bool:
	return _is_safe_runtime_path(path) and path.ends_with(".json")


func _is_safe_runtime_dependency_path(path: String) -> bool:
	return (_is_safe_runtime_path(path) or path.begins_with("res://generated/world/")) \
		and not path.contains("..") \
		and not path.contains("\\") \
		and _runtime_asset_text_is_clean(path)


func _is_safe_runtime_path(path: String) -> bool:
	return path.begins_with("res://game/") \
		and not path.contains("..") \
		and not path.contains("\\") \
		and _runtime_asset_text_is_clean(path)


func _runtime_asset_text_is_clean(text: String) -> bool:
	var slash := "/"
	return not text.contains("discovery" + slash) \
		and not text.contains("evidence" + slash) \
		and not text.contains(slash + "Users" + slash) \
		and not text.contains(slash + "Volumes" + slash) \
		and not text.contains("http:" + slash + slash) \
		and not text.contains("https:" + slash + slash)


func _runtime_boundary_is_clean(value: Variant) -> bool:
	match typeof(value):
		TYPE_STRING:
			return _runtime_asset_text_is_clean(str(value))
		TYPE_ARRAY:
			for child: Variant in value as Array:
				if not _runtime_boundary_is_clean(child):
					return false
			return true
		TYPE_DICTIONARY:
			for child: Variant in (value as Dictionary).values():
				if not _runtime_boundary_is_clean(child):
					return false
			return true
	return true


func _has_exact_keys(value: Dictionary, expected: Array) -> bool:
	var actual := value.keys()
	var wanted := expected.duplicate()
	actual.sort()
	wanted.sort()
	return actual == wanted


func _is_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for index in value.length():
		var character := value.substr(index, 1)
		if not "0123456789abcdef".contains(character):
			return false
	return true


func _read_json(path: String, error_code: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_require(false, error_code, "JSON file cannot be opened: %s" % path)
		return null
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	if parse_error != OK:
		_require(false, error_code, "JSON parse failed at line %d: %s" % [parser.get_error_line(), parser.get_error_message()])
		return null
	return parser.data


func _resolution_failure(code: String, message: String) -> Dictionary:
	return {
		"error_code": code,
		"error_message": message,
		"ok": false,
	}


func _require(condition: bool, code: String, message: String) -> bool:
	if condition:
		return true
	if _last_error_code.is_empty():
		_last_error_code = code
		_last_error_message = message
	return false


func _has_error() -> bool:
	return not _last_error_code.is_empty()


func _status() -> Dictionary:
	return {
		"error_code": _last_error_code,
		"error_message": _last_error_message,
		"ok": false,
	}


func _reset() -> void:
	_loaded = false
	_registry = {}
	_adapter_contracts = {}
	_units_by_id = {}
	_receivers_by_key = {}
	_adapters_by_id = {}
	_plans_by_receiver = {}
	_projections_by_id = {}
	_last_error_code = ""
	_last_error_message = ""

func _validate_northern_1201_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1201_parity_mismatch", "1201 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1201_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215672"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1201_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1201_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1201_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1201_parity_mismatch",
		"1201 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 20,
		"northern_1201_parity_mismatch",
		"1201 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1201_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1201_parity_mismatch", "1201 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1201_parity_mismatch",
		"1201 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1201_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1201_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1201_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1201_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1201_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1201_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/northern_canopy_free_live_replacement.gd", "8967229a37be5401962132b846b08f1f527fb27f6aae3cd2d6d97eb70f608b82")
		and _runtime_asset_match(assets, "res://game/resources/facades/northern_canopy_free_study.json", "54659ba6dde676f8a3ea122d654ff9532ffc706c6ea95b0913e4ef10fa5100b0")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/northern_canopy_free_live_factory.gd", "2a01cf9fe20d81b381e445e3531377a2802082f69424445196ede570d15b2f96")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1201_parity_mismatch",
		"1201 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.northern-canopy-free-study/1\",\"source_key\":\"w96215672\",\"chunk_id\":\"x_-2__z_-3\",\"chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"mapped_runs\":[11,12,14,15,17,18],\"protected_runs\":[0,1,2,3,4,5,6,7,8,9,10,13,16,19]}"), "northern_1201_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1201_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1201_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1201-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "fc250debbc032d160e3de5e3e0148f13934a7e3bb17cc882a19f4d5b336fab95"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "5a5de738ac8e8ed4490d4c83d63a739d5cdb9598ce66021984579dac1bf6e0c4"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "c0fcacf741e513402d0b04aa35c7d5927b4205ebb80c85890a62bd2b5456c77d"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "21be51860e8e35dcdf76df4753d22155cbca013f134250b365764e873b8eac86"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "df08d70aa4307e2b7689e6c8e3ff0ad31005806b14c2420251456ddb4c60db92"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "f449c7863040df9873f5bcd268e0eac506a9c26d6e0613881e1b294e9355bb1f"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "11f87bb5defc8432d5ba53e8e2eb586f631cd81db920f5fa85dc61cc34261589"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215672"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "15/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215672"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215672:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215672:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [11, 12, 14, 15, 17, 18])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 16, 19])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 11.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 11.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 4950.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [10, 10, 4940, 2, 8])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [1, 1, 10, 1, 1])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1050.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1065.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 108921.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 468.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 492.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "shared_northern_1201_1238_candidate_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 3.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 9.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 8
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "MaroonClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "station_held_claimed"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == true,
		"northern_1201_parity_mismatch",
		"1201 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1201_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/northern_canopy_free_live_replacement.gd", NORTHERN_1201_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/northern_canopy_free_live_factory.gd", NORTHERN_1201_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1201_SITE_KIT_SHA256),
		"northern_1201_parity_mismatch",
		"1201 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)



func _validate_northern_1238_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1238_parity_mismatch", "1238 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1238_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215669"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1238_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1238_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1238_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1238_parity_mismatch",
		"1238 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 24,
		"northern_1238_parity_mismatch",
		"1238 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1238_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1238_parity_mismatch", "1238 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1238_parity_mismatch",
		"1238 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1238_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1238_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1238_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1238_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1238_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1238_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/northpoint_1238_live_replacement.gd", "fef8305341da71b88c1fa90a5ccdd9bba98afc10f999de7208cc6373ff7ba9c3")
		and _runtime_asset_match(assets, "res://game/resources/facades/northpoint_1238_study.json", "a7f733e4f67351f9919769ff1329f263efbd43ca0d39a3fb30c3ac77e626c2a9")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/northpoint_1238_live_factory.gd", "2046c934f4fdaa35f12c7e343910b26a7e1cb2d7e489adc22467bcd1b41bb45f")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1238_parity_mismatch",
		"1238 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.northpoint-1238-study/1\",\"source_key\":\"w96215669\",\"chunk_id\":\"x_-1__z_-4\",\"chunk_sha256\":\"bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac\",\"mapped_runs\":[8,9,10,11,13,14,15,17,18,19,20,21],\"protected_runs\":[0,1,2,3,4,5,6,7,12,16,22,23]}"), "northern_1238_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1238_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1238_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1238-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "5eb7648cb03fa1ae73c9733c31456539d39c40a462219be43d4a92ecf7d0ce62"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "fb3f03daae24bb385cbf6e86ee665a2752017ee9c5c32f54c6e21d00dbc7faf3"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "35edd4f41d0cf9009aa59f66b0345992a93bb08ecd1eda8b61086b6eb5dc09db"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "5b6b2455b8068568e2b877b9f155982af76e4cc81f7be3341e9ec663c7c260de"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "a2e2b8aade40eebd01d900728e65c5cabd2cb1f43465399db2ed90329d49a741"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "6e5961faa00944e793c213e444a96732494a6fe15e1799f06636bdd1dd7ad276"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "805f12798185ad8504cfac0742a27bdcb83c9da79b9aa9a192ba84081117fbab"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215669"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "16/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215669"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215669:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215669:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [8, 9, 10, 11, 13, 14, 15, 17, 18, 19, 20, 21])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 12, 16, 22, 23])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 11.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 11.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 4956.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [10, 10, 4940, 2, 8])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [1, 1, 16, 1, 1])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1050.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1065.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 108921.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 468.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 492.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "pre_mariner_batch_integration_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 3.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 9.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 8
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "DarkBlueClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "station_held_claimed"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == false,
		"northern_1238_parity_mismatch",
		"1238 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1238_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/northpoint_1238_live_replacement.gd", NORTHERN_1238_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/northpoint_1238_live_factory.gd", NORTHERN_1238_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1238_SITE_KIT_SHA256),
		"northern_1238_parity_mismatch",
		"1238 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)




static func begin_measurement() -> void:
	_measurement = {"hash_calls": 0, "hash_bytes": 0, "hash_usec": 0, "closure_read_calls": 0, "closure_read_bytes": 0, "closure_read_usec": 0}
	_measurement_enabled = true


static func measurement_snapshot() -> Dictionary:
	return _measurement.duplicate(true)


static func end_measurement() -> Dictionary:
	_measurement_enabled = false
	return measurement_snapshot()


func _measured_file_sha256(path: String) -> String:
	if not _measurement_enabled:
		return FileAccess.get_sha256(path)
	var started_usec: int = Time.get_ticks_usec()
	var digest: String = FileAccess.get_sha256(path)
	var elapsed_usec: int = Time.get_ticks_usec() - started_usec
	_measurement.hash_calls += 1
	_measurement.hash_usec += elapsed_usec
	var observed_file := FileAccess.open(path, FileAccess.READ)
	if observed_file != null:
		_measurement.hash_bytes += observed_file.get_length()
	return digest

func _validate_northern_1206_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1206_parity_mismatch", "1206 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1206_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215677"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1206_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1206_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1206_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1206_parity_mismatch",
		"1206 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 26,
		"northern_1206_parity_mismatch",
		"1206 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1206_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1206_parity_mismatch", "1206 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1206_parity_mismatch",
		"1206 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1206_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1206_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1206_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1206_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1206_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1206_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/mariner_1206_live_replacement.gd", "88e0858a2b9d3559c8d2e766874f93cd44335f89c232e8115ef7c7f97ecc951b")
		and _runtime_asset_match(assets, "res://game/resources/facades/mariner_1206_study.json", "5327998befca469042db9ac728de697e56fb311f9f889bb1bc867617425d4f97")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/mariner_1206_live_factory.gd", "906922118fd881a5668962c87964b8c46db32d92a5483fd072a4c2a90b521c56")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1206_parity_mismatch",
		"1206 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.mariner-1206-study/1\",\"source_key\":\"w96215677\",\"chunk_id\":\"x_-2__z_-3\",\"chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"mapped_runs\":[11,12,13,15,16,17,18,19,21,22,23],\"protected_runs\":[0,1,2,3,4,5,6,7,8,9,10,14,20,24,25]}"), "northern_1206_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1206_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1206_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1206-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "2ef58e0ef4ab39375107bf4d5354b83399eceda0bc36599b7bbb5e98bb79e6b9"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "bd5aacf373d887cddf2c25ed0788ab0286faa0c9daa7cc0e9e03a81ad744bd0e"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "6bee171a27e3a10b3f1927f332a678ec0826e982faa6085e71db525bcdb30096"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "03f2cf746dc931dd816f28f337b12ae9f11d7cb5ef3c3087601a46bb9df427c7"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "70f69ef17176b2810b073f4304fd17f6bc7143a70ac031d1a20922996422661c"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "c806dc1fd6f146f8573e83b3fd8ac8523d87fba1d57e8f5e9d29a066b481f3bd"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "b3549c8b8616163a06c8fa2209562bda58ad9ce03ad3ae68751c9ca256b9e09a"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215677"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "16/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215677"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215677:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215677:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [11, 12, 13, 15, 16, 17, 18, 19, 21, 22, 23])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 14, 20, 24, 25])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 5132.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [12, 12, 5068, 2, 8])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [2, 2, 64, 2, 2])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1074.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1089.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 119049.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 472.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 508.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "shared_mariner_1206_1219_candidate_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "added_public_roof_triangles", "original_flat_roof_preserved", "added_public_roof_is_nonreceiver", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 4.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 10.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 8
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "GreenClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 2
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1] == "ObservedPublicRoof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) == 48.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "station_held_claimed"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == true,
		"northern_1206_parity_mismatch",
		"1206 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1206_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/mariner_1206_live_replacement.gd", NORTHERN_1206_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/mariner_1206_live_factory.gd", NORTHERN_1206_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1206_SITE_KIT_SHA256),
		"northern_1206_parity_mismatch",
		"1206 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)



func _validate_northern_1219_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1219_parity_mismatch", "1219 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1219_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215680"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1219_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1219_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1219_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1219_parity_mismatch",
		"1219 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 26,
		"northern_1219_parity_mismatch",
		"1219 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1219_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1219_parity_mismatch", "1219 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1219_parity_mismatch",
		"1219 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1219_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1219_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1219_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1219_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1219_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1219_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/mariner_1219_live_replacement.gd", "c6a0c16cc762d33c62c3f3885d865999be5e65e148f56a66e9da348e6cbfb58a")
		and _runtime_asset_match(assets, "res://game/resources/facades/mariner_1219_study.json", "5fd7eeb31c4d2cfac52aadff65f1bc7f35458d3e0c8d8469411f75ce032b9f21")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/mariner_1219_live_factory.gd", "216e83f6ee69313d77ef5c2007720a126e07cff5e30ce23401a1d28cdac84748")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1219_parity_mismatch",
		"1219 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.mariner-1219-study/1\",\"source_key\":\"w96215680\",\"chunk_id\":\"x_-2__z_-3\",\"chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"mapped_runs\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13],\"protected_runs\":[14,15,16,17,18,19,20,21,22,23,24,25]}"), "northern_1219_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1219_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1219_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1219-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "892c34c422283ba7eadd3b5a8d005f34b8736e4b359ffc67ba7194a6c4fc110d"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "98fe533ab07e2ff5f098094ad68e2b32b20712e13de75881e679eb84fb107c0f"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "754b234c8806726b70400dcd759abbed3a309fad42be12669b2cf877e6e5b415"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "4c2e64ec36a96058c8d48a7cb5f5e9c29c0e1154ff2c2db179071cc8f7553e62"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "bd06a1a34a11937410f82ad5d6903de68e8d0a1660b5a9b2d8815afeee990ea6"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "03003e86b6fb4b7fb28099876e6a788e9c8596bd14f25a794d8a1adce6fd4ecd"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "f58284bed7ac7fce861a282a344bac1cdb12d6b69286d0cfbde3936f9022139b"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215680"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "16/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215680"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215680:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215680:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 5132.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [12, 12, 5068, 2, 8])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [2, 2, 64, 2, 2])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1074.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1089.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 119049.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 472.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 508.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "pre_northern_three_unit_integration_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "added_public_roof_triangles", "original_flat_roof_preserved", "added_public_roof_is_nonreceiver", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 4.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 10.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 8
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "DarkBlueClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 2
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1] == "ObservedPublicRoof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) == 48.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "station_held_claimed"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == true,
		"northern_1219_parity_mismatch",
		"1219 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1219_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/mariner_1219_live_replacement.gd", NORTHERN_1219_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/mariner_1219_live_factory.gd", NORTHERN_1219_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1219_SITE_KIT_SHA256),
		"northern_1219_parity_mismatch",
		"1219 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)

func _validate_northern_1212_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1212_parity_mismatch", "1212 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1212_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215649"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1212_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1212_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1212_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1212_parity_mismatch",
		"1212 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 28,
		"northern_1212_parity_mismatch",
		"1212 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1212_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1212_parity_mismatch", "1212 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1212_parity_mismatch",
		"1212 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1212_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1212_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1212_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1212_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1212_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1212_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/mariner_1212_live_replacement.gd", "c0941706e3cee909b260e278a07d846932b805aaeb5e12440463e43678b3513c")
		and _runtime_asset_match(assets, "res://game/resources/facades/mariner_1212_study.json", "f56009b6ccb5bea7ed63911c7d940573996aad4e1c5ccaa55267adbd150b3066")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/mariner_1212_live_factory.gd", "0594ea7a6e1f09a918349ee5af58722896e3b300ae640d8c1d4025b8219bc2a9")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1212_parity_mismatch",
		"1212 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.mariner-1212-study/1\",\"source_key\":\"w96215649\",\"chunk_id\":\"x_-1__z_-3\",\"chunk_sha256\":\"d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc\",\"mapped_runs\":[14,15,16,17,19,20,21,22,24,25,26,27],\"protected_runs\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,18,23]}"), "northern_1212_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1212_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1212_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1212-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "e639c2fe4ca2beebdd067a8d804d231ba4e4a9e55e4d85699496533479267de2"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "e78ac76b320df4869bc882a52e5e37ad56a863f5e99734d9b45e2d84764a6424"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "e094b27c9dc69797035270a9acfedcb4db9832338f4915178e101f05621b49af"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "276b71133a8ae9c1f0fd8caecdbd0365f16c3ca4655d49e99149bbaec61b0ae0"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "0c46621cf3d43660a7e7d8168dcdf0be5556d96b5ff1a63b0715295311565d35"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "6f67a10d85551c5e4226ff47edcd15a15ce25f3a179ffa0e3670d3c0981be3fb"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "bbc33d45ea0708df973adc24897b27ceaa052117c4f002546df64b2fdb30ef3d"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215649"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "18/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215649"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215649:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215649:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [14, 15, 16, 17, 19, 20, 21, 22, 24, 25, 26, 27])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 18, 23])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 5140.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [12, 12, 5076, 2, 8])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [2, 2, 64, 2, 2])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1111.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1126.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 138057.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 478.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 533.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "shared_northern_1212_1220_1239_candidate_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "added_public_roof_triangles", "original_flat_roof_preserved", "added_public_roof_is_nonreceiver", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 4.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 10.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 8
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "DarkReddishClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 2
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1] == "ObservedPublicRoof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) == 48.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "station_held_claimed", "prior_clipped_tag_failure_retained", "scoped_hairline_observation_retained", "native_support_qualification_mm"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm"))) and float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) == 4.0,
		"northern_1212_parity_mismatch",
		"1212 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1212_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/mariner_1212_live_replacement.gd", NORTHERN_1212_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/mariner_1212_live_factory.gd", NORTHERN_1212_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1212_SITE_KIT_SHA256),
		"northern_1212_parity_mismatch",
		"1212 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)



func _validate_northern_1220_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1220_parity_mismatch", "1220 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1220_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215652"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1220_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1220_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1220_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1220_parity_mismatch",
		"1220 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 26,
		"northern_1220_parity_mismatch",
		"1220 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1220_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1220_parity_mismatch", "1220 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1220_parity_mismatch",
		"1220 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1220_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1220_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1220_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1220_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1220_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1220_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/bayside_1220_live_replacement.gd", "1edb75f24c3de6b4c6c780c9bb6b478225925453872e11c76f82fece8a146c38")
		and _runtime_asset_match(assets, "res://game/resources/facades/bayside_1220_study.json", "984ebbde55fa5dcb1cea8b0d57c20e2773982bbb195e1a52b16dec250ec0735b")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/bayside_1220_live_factory.gd", "dcfb622e4f5d2759459e17d1ab465ae9fa772167f335a2d1e0c88a111482273d")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1220_parity_mismatch",
		"1220 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.bayside-1220-study/1\",\"source_key\":\"w96215652\",\"chunk_id\":\"x_-2__z_-3\",\"chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"mapped_runs\":[0,1,3,4,5,6,7,8,10,11],\"protected_runs\":[2,9,12,13,14,15,16,17,18,19,20,21,22,23,24,25]}"), "northern_1220_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1220_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1220_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1220-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "410d90ee3599491993fddcc0ed8accea3de05bb4e905be9076078629b36f7835"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "94994da3f3db23d5bc81d4892e7ddcbafe91228aa891890198b9afee0339e961"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "db006b21c253ea7dbcc937ff6ba5bf7805894f9b00b8ef6164396ee9f6b3af23"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "dbef975d3b3afedac4694ea49c57f4e98e50a41f67ed2a61621dae3cc0c12176"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "1d2e5d2682e0b72c9c81b5962680e11c9cdba200d0ab13b11db1c6dac54f1aef"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "923517f30c75e83af49c039111fdac548d8a20c0486cdf202863e04cca41c3ef"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "ca45fe7f855fb98ecadecddf7a04e8b9e13f73355bed128cfc4c8ef83a13fc1c"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215652"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "18/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215652"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215652:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215652:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [0, 1, 3, 4, 5, 6, 7, 8, 10, 11])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [2, 9, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 14.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 7118.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [12, 12, 7040, 2, 8])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [2, 2, 78, 2, 2])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1111.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1126.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 138057.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 478.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 533.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "shared_northern_1212_1220_1239_candidate_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "added_public_roof_triangles", "original_flat_roof_preserved", "added_public_roof_is_nonreceiver", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 4.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 10.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 8
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "DarkBlueClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 2
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1] == "ObservedPublicRoof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) == 64.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "station_held_claimed", "prior_clipped_tag_failure_retained", "scoped_hairline_observation_retained", "native_support_qualification_mm"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm"))) and float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) == 4.0,
		"northern_1220_parity_mismatch",
		"1220 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1220_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/bayside_1220_live_replacement.gd", NORTHERN_1220_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/bayside_1220_live_factory.gd", NORTHERN_1220_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1220_SITE_KIT_SHA256),
		"northern_1220_parity_mismatch",
		"1220 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)



func _validate_northern_1239_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1239_parity_mismatch", "1239 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1239_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215658"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1239_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1239_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1239_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1239_parity_mismatch",
		"1239 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 34,
		"northern_1239_parity_mismatch",
		"1239 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1239_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1239_parity_mismatch", "1239 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1239_parity_mismatch",
		"1239 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1239_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1239_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1239_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1239_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1239_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1239_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/northpoint_1239_live_replacement.gd", "e397a0879a8beb8eca7e8ec32e80c40652cfb1b5b67a50bf6f52952f4ae44aa5")
		and _runtime_asset_match(assets, "res://game/resources/facades/northpoint_1239_study.json", "bf1a2073f0d371242d5636dcb47820cb6cbf47f8df9300de7aab95da3cfa6174")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/northpoint_1239_live_factory.gd", "3573433b35a317f40f908c64ef05519559918f5ccca0f9af14849af2b932732d")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1239_parity_mismatch",
		"1239 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.northpoint-1239-study/1\",\"source_key\":\"w96215658\",\"chunk_id\":\"x_-1__z_-4\",\"chunk_sha256\":\"bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac\",\"mapped_runs\":[0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,18],\"protected_runs\":[9,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33]}"), "northern_1239_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1239_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1239_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1239-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "640768775dc2090c5742eb1b8468f0a9992086fbe06cca8ae8f5982309b20ee6"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "be716635b72e105c8440c51836735e149360f20eda1fdc95b9a0bfd83f39a6e2"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "47f2d83b04b14b988f9b72c22b8384120201eba933a0a9fd7ca1dd7163eda22c"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "2e57bb89f4e646abc95a7db1a7cea82100c058121ad6755ff08edd1fd6403be2"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "7da899b63a2f906a643ac3eeb3a92a793fa3b502e9fa60f395b58fe60139d3e0"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "d45db6575672f8c713ce96ec41d577d507722a57c14417657f7c2cc564f70f81"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "f46366f21b1cc5ed5fb2a230fd35cdc144d02b24833292b9c1ad617f58191c55"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215658"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "18/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215658"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215658:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215658:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 16, 17, 18])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [9, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 15.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 15.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 6978.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [13, 13, 6892, 2, 9])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [2, 2, 86, 2, 2])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1111.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1126.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 138057.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 478.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 533.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "pre_northern_1222_1227_1202_integration_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "added_public_roof_triangles", "original_flat_roof_preserved", "added_public_roof_is_nonreceiver", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 4.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 11.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 9
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "OchreClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "MutedRoseClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[8]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[8] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 2
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[1] == "ObservedPublicRoof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) == 64.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "station_held_claimed", "prior_clipped_tag_failure_retained", "scoped_hairline_observation_retained", "native_support_qualification_mm"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm"))) and float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) == 4.0,
		"northern_1239_parity_mismatch",
		"1239 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1239_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/northpoint_1239_live_replacement.gd", NORTHERN_1239_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/northpoint_1239_live_factory.gd", NORTHERN_1239_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1239_SITE_KIT_SHA256),
		"northern_1239_parity_mismatch",
		"1239 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)

func _validate_northern_1222_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1222_parity_mismatch", "1222 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1222_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215661"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1222_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1222_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1222_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1222_parity_mismatch",
		"1222 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 20,
		"northern_1222_parity_mismatch",
		"1222 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1222_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1222_parity_mismatch", "1222 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1222_parity_mismatch",
		"1222 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1222_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1222_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1222_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1222_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1222_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1222_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/bayside_1222_live_replacement.gd", "a4f6e7242dd4130b3dca67cad165a8a3067129ab2a7455e4e0f0f76ef3c144bf")
		and _runtime_asset_match(assets, "res://game/resources/facades/bayside_1222_study.json", "65a67decfd83b376209c8c8f80ab7f456be2006a8a907c2f36211c3e863e0ab2")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/bayside_1222_live_factory.gd", "639a5ce1cce22b5635f3bccfe6cb1c7764988662b826f0c25c4183fe2ec787f9")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1222_parity_mismatch",
		"1222 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.bayside-1222-study/1\",\"source_key\":\"w96215661\",\"chunk_id\":\"x_-2__z_-3\",\"chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"mapped_runs\":[10,11,12,13,14,15,16,19],\"protected_runs\":[0,1,2,3,4,5,6,7,8,9,17,18]}"), "northern_1222_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1222_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1222_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1222-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "c9bdee01510d7e0c2f43be4c454b154437009583b2c59c15ba211f07ee16f259"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "ac2950c05d8472b5a8edb0ce2f7b4437159d6af963145dfd142ec5bc59019b98"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "0976e8393145f40ce9e07c861bdc1a032f15b0cf70e6c984244318e2adfb92d3"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "a6ea228918898454c56fd5aebe1affbd94d0bc7c1878c966c14fc704409e028b"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "4870b6e92d8d9d42c7107a27f38af1f115f39cd934e920d297363c018d3d2822"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "ec1e740bd93a8325094811bf634d90d43c672574a002a90c96a1a454662996cf"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "20a5a14b31c9918f7e9e4c3884c1ca3deef55af1ccd5720c4c9d581710c42f76"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215661"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "23/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215661"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215661:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215661:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [10, 11, 12, 13, 14, 15, 16, 19])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 17, 18])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 16.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 16.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 5346.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [15, 15, 5336, 3, 11])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [1, 1, 10, 1, 1])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1159.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1174.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 153873.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 484.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 569.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "shared_northern_1222_1227_1202_candidate_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "original_wall_and_projected_front_are_receivers", "projected_receiver_runs", "projected_receiver_triangles", "projected_receiver_shape_order", "projected_receiver_physics_layer", "projected_receiver_cull_mask", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "added_public_roof_triangles", "original_flat_roof_preserved", "added_public_roof_is_nonreceiver", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 4.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 12.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_wall_and_projected_front_are_receivers")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_wall_and_projected_front_are_receivers") == true
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("projected_receiver_runs") as Array), [10, 11, 12, 15, 16, 19])
		and typeof((contract.get("ownership_contract") as Dictionary).get("projected_receiver_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_triangles")) == 6.0
		and ((contract.get("ownership_contract") as Dictionary).get("projected_receiver_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("projected_receiver_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("projected_receiver_shape_order") as Array)[0] == "ProjectedUpperSiding"
		and typeof((contract.get("ownership_contract") as Dictionary).get("projected_receiver_physics_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_physics_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_physics_layer")) == 5.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("projected_receiver_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_cull_mask")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 10
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "ProjectedUpperClosures"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "BlueGrayClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "PaleClosedDoor"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[8]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[8] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[9]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[9] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "original_visual_hold_retained", "metadata_only_observer_retained", "unexecuted_central_carport_proposal_retained", "motion_route_scope", "station_held_claimed", "prior_clipped_tag_failure_retained", "scoped_hairline_observation_retained", "native_support_qualification_mm"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("original_visual_hold_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("original_visual_hold_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("metadata_only_observer_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("metadata_only_observer_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unexecuted_central_carport_proposal_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unexecuted_central_carport_proposal_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("motion_route_scope")) == TYPE_STRING and (contract.get("truth_boundary") as Dictionary).get("motion_route_scope") == "one_door_one_screen_finite_routes"
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm"))) and float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) == 4.0,
		"northern_1222_parity_mismatch",
		"1222 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1222_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/bayside_1222_live_replacement.gd", NORTHERN_1222_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/bayside_1222_live_factory.gd", NORTHERN_1222_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1222_SITE_KIT_SHA256),
		"northern_1222_parity_mismatch",
		"1222 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)



func _validate_northern_1227_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1227_parity_mismatch", "1227 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1227_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215653"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1227_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1227_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1227_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1227_parity_mismatch",
		"1227 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 22,
		"northern_1227_parity_mismatch",
		"1227 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1227_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1227_parity_mismatch", "1227 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1227_parity_mismatch",
		"1227 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1227_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1227_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1227_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1227_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1227_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1227_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/northpoint_1227_live_replacement.gd", "ace49917dc8935c75124e70f3dc573330a2236a6a82ef948b41b1eeeee451c6e")
		and _runtime_asset_match(assets, "res://game/resources/facades/northpoint_1227_study.json", "2e8573eb855c110c0d13545d63f8fd467a25a68613d16b91cb1336462baadde7")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/northpoint_1227_live_factory.gd", "6492b8e48226ed09c7e7171bd7fd51e25b8e347c38d87d2d0931b2b3337fb2f4")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1227_parity_mismatch",
		"1227 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.northpoint-1227-study/1\",\"source_key\":\"w96215653\",\"chunk_id\":\"x_-2__z_-4\",\"chunk_sha256\":\"932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4\",\"mapped_runs\":[4,5,6,7,8,9,10,11,13,14,15,16,17],\"protected_runs\":[0,1,2,3,12,18,19,20,21]}"), "northern_1227_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1227_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1227_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1227-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "f240c0a442a66cdb5e20fffa4883e2b9098ce681d0fdefa3c30e846e376d517b"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "c45ad15c677f1413d106695f8a1c6e339c0b6da6f4fb67eea0d9b6ae53b64018"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "a28bf431f24e58cc147b3adc6df9983784f68d6f0335c61bea3bda7d02e0cfa8"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "802e3287f84f0363a688d35454e88aebef7d34b93db88b88d16785311ec3d7d4"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "34e252f76805cd5e152fd58056f95852ba5c4ebfdc2e73ceeb20f1410c74eadb"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "45cf53232bcb34f4bf43b2370a7ce0e84ade628dc23e9aa7a8439f70eb102c03"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "8957bff439a37e22880af8b0df5c6641e348bb19e13207bd65ac8e94cb1484ad"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215653"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "23/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215653"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215653:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215653:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 1, 2, 3, 12, 18, 19, 20, 21])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 20.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 20.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 5544.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [19, 19, 5528, 3, 15])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [1, 1, 16, 1, 1])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1159.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1174.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 153873.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 484.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 569.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "shared_northern_1222_1227_1202_candidate_live_parity"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "original_wall_and_projected_front_are_receivers", "projected_receiver_runs", "projected_receiver_triangles", "projected_receiver_shape_order", "projected_receiver_physics_layer", "projected_receiver_cull_mask", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "added_public_roof_triangles", "original_flat_roof_preserved", "added_public_roof_is_nonreceiver", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 4.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 16.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_wall_and_projected_front_are_receivers")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_wall_and_projected_front_are_receivers") == true
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("projected_receiver_runs") as Array), [4, 5, 6, 7, 9, 10, 11, 13, 14, 15, 16])
		and typeof((contract.get("ownership_contract") as Dictionary).get("projected_receiver_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_triangles")) == 6.0
		and ((contract.get("ownership_contract") as Dictionary).get("projected_receiver_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("projected_receiver_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("projected_receiver_shape_order") as Array)[0] == "ProjectedUpperSiding"
		and typeof((contract.get("ownership_contract") as Dictionary).get("projected_receiver_physics_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_physics_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_physics_layer")) == 5.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("projected_receiver_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_cull_mask")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 14
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "ObservedPublicRoof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "NorthGableSiding"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "CarportRoof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "CarportPosts"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "ProjectedUpperClosures"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[8]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[8] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[9]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[9] == "BlueGrayClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[10]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[10] == "PaleClosedDoor"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[11]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[11] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[12]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[12] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[13]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[13] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) == 92.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "original_visual_hold_retained", "metadata_only_observer_retained", "unexecuted_central_carport_proposal_retained", "motion_route_scope", "station_held_claimed", "prior_clipped_tag_failure_retained", "scoped_hairline_observation_retained", "native_support_qualification_mm"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("original_visual_hold_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("original_visual_hold_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("metadata_only_observer_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("metadata_only_observer_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unexecuted_central_carport_proposal_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unexecuted_central_carport_proposal_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("motion_route_scope")) == TYPE_STRING and (contract.get("truth_boundary") as Dictionary).get("motion_route_scope") == "one_door_one_screen_finite_routes"
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm"))) and float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) == 4.0,
		"northern_1227_parity_mismatch",
		"1227 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1227_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/northpoint_1227_live_replacement.gd", NORTHERN_1227_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/northpoint_1227_live_factory.gd", NORTHERN_1227_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1227_SITE_KIT_SHA256),
		"northern_1227_parity_mismatch",
		"1227 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)



func _validate_northern_1202_registry_adapter(adapter: Dictionary) -> bool:
	if not _require(not adapter.is_empty(), "northern_1202_parity_mismatch", "1202 exact-current paired wall/roof adapter is missing."):
		return false
	if not _require(
		str(adapter.get("adapter_id", "")) == NORTHERN_1202_ADAPTER_ID
		and str(adapter.get("source_key", "")) == "w96215651"
		and str(adapter.get("receiver_key", "")) == NORTHERN_1202_RECEIVER
		and str(adapter.get("attachment_kind", "")) == "active_northern_1202_paired_wall_roof_replacement"
		and str(adapter.get("content_classification", "")) == "active_target_specific_paired_wall_roof_replacement"
		and str(adapter.get("runtime_content_mode", "")) == "active_northern_1202_paired_replacement"
		and str(adapter.get("state", "")) == "active_runtime_target_specific_content"
		and str(adapter.get("recognition_acceptance_status", "")) == "accepted"
		and str(adapter.get("recognition_claim_effect", "")) == "none"
		and (adapter.get("accepted_run_scopes", []) as Array).is_empty()
		and (adapter.get("runtime_asset_projections", []) as Array).is_empty(),
		"northern_1202_parity_mismatch",
		"1202 active adapter identity, paired classification, acceptance, or package boundary drifted.",
	):
		return false
	var receiver_scope := adapter.get("active_receiver_scope", {}) as Dictionary
	if not _require(
		_has_exact_keys(receiver_scope, ["coverage", "run_count"])
		and str(receiver_scope.get("coverage", "")) == "whole_direct_wall_receiver"
		and int(receiver_scope.get("run_count", -1)) == 26,
		"northern_1202_parity_mismatch",
		"1202 active receiver scope does not cover the exact source-run direct wall receiver.",
	):
		return false
	var assets := adapter.get("runtime_assets", []) as Array
	var actual_paths := []
	for asset_value: Variant in assets:
		actual_paths.append(str((asset_value as Dictionary).get("path", "")))
	actual_paths.sort()
	var expected_paths := NORTHERN_1202_RUNTIME_ASSETS.duplicate()
	expected_paths.sort()
	if not _require(actual_paths == expected_paths, "northern_1202_parity_mismatch", "1202 active adapter does not contain its exact 5-asset paired runtime closure."):
		return false
	var runtime_contract := adapter.get("active_runtime_contract", {}) as Dictionary
	if not _require(
		_has_exact_keys(runtime_contract, ["adapter_sha256", "behavior_contract", "config_sha256", "config_summary", "dispatch_sha256", "prototype_config_sha256", "prototype_sha256", "site_kit_sha256"]),
		"northern_1202_parity_mismatch",
		"1202 active runtime contract fields drifted.",
	):
		return false
	if not _require(
		str(runtime_contract.get("adapter_sha256", "")) == NORTHERN_1202_ADAPTER_SHA256
		and str(runtime_contract.get("config_sha256", "")) == NORTHERN_1202_CONFIG_SHA256
		and str(runtime_contract.get("dispatch_sha256", "")) == NORTHERN_1202_BUILDER_SHA256
		and str(runtime_contract.get("prototype_sha256", "")) == NORTHERN_1202_PROTOTYPE_SHA256
		and str(runtime_contract.get("prototype_config_sha256", "")) == NORTHERN_1202_PROTOTYPE_CONFIG_SHA256
		and str(runtime_contract.get("site_kit_sha256", "")) == NORTHERN_1202_SITE_KIT_SHA256
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/mariner_1202_live_replacement.gd", "29f17b796ae922d967e87212f7e3ed21fa30db7d9ce4b9c2c7a2ba079e847a70")
		and _runtime_asset_match(assets, "res://game/resources/facades/mariner_1202_study.json", "8490ec8dab6302c9892b37b86542ccc18793dfe309ac7d589fb9dc9cad9ddf22")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/mariner_1202_live_factory.gd", "c81cf174af5f91a21dc95306b77296d8d82152a54ef301e87853944b3b78c59c")
		and _runtime_asset_match(assets, "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader", "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a")
		and _runtime_asset_match(assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd"),
		"northern_1202_parity_mismatch",
		"1202 adapter/config/dispatch/prototype/site-kit pins do not bind the exact reviewed bytes.",
	):
		return false
	return _require(runtime_contract.get("config_summary", {}) == JSON.parse_string("{\"schema_version\":\"ti.mariner-1202-study/1\",\"source_key\":\"w96215651\",\"chunk_id\":\"x_-2__z_-3\",\"chunk_sha256\":\"7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5\",\"mapped_runs\":[10,11,12,13,14,15,16,17,18,19,21],\"protected_runs\":[0,1,2,3,4,5,6,7,8,9,20,22,23,24,25]}"), "northern_1202_parity_mismatch", "Exact northern source scope summary drifted.") and _validate_northern_1202_behavior_contract(runtime_contract.get("behavior_contract", {}) as Dictionary)


func _validate_northern_1202_behavior_contract(contract: Dictionary) -> bool:
	return _require(
		_has_exact_keys(contract, ["schema_version", "acceptance_contract", "replacement_contract", "geometry_contract", "ownership_contract", "truth_boundary"])
		and typeof(contract.get("schema_version")) == TYPE_STRING and contract.get("schema_version") == "ti.northern-1202-production-live-parity/1"
		and _has_exact_keys((contract.get("acceptance_contract") as Dictionary), ["evidence_manifest_sha256", "motion_telemetry_manifest_sha256", "visual_motion_manifest_sha256", "package_verification_receipt_sha256", "evidence_tree_sha256", "mechanical_review_receipt_sha256", "review_receipt_sha256", "accepted_physical_unit_id", "capture_time_recognition_metric", "numerator_effect", "reference_recognizable", "wall_and_roof_are_one_physical_unit"])
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_manifest_sha256") == "497ce96296ada0265a26c4d24215db320b278cff8883be00b5d637a94d2cfd64"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("motion_telemetry_manifest_sha256") == "8205cf8904929d56d9e90842922a6be37cf64869f283c60aac666e42e571c236"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("visual_motion_manifest_sha256") == "4de165e49df045101b1fd7156f0f7595c0026617db255ab3c23412b1a4424081"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("package_verification_receipt_sha256") == "1da322cc863b923b4befee6eac8f3876c1fa0360a1848527c88cba774c935769"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("evidence_tree_sha256") == "3c30e9c73026a885f2ee2b3941b28e7ed6be799571c58fa733d2e209adfad7fe"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("mechanical_review_receipt_sha256") == "669f108baf4c343f766da111c808232e6b4b611d13cf919526372e54f8642d34"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("review_receipt_sha256") == "6a7813fc1a94f816bd01f55f6901a61f7d421b67e085663b6e51ad865408754e"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("accepted_physical_unit_id") == "physical-building:w96215651"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric")) == TYPE_STRING and (contract.get("acceptance_contract") as Dictionary).get("capture_time_recognition_metric") == "23/213"
		and typeof((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect"))) and float((contract.get("acceptance_contract") as Dictionary).get("numerator_effect")) == 1.0
		and typeof((contract.get("acceptance_contract") as Dictionary).get("reference_recognizable")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("reference_recognizable") == true
		and typeof((contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit")) == TYPE_BOOL and (contract.get("acceptance_contract") as Dictionary).get("wall_and_roof_are_one_physical_unit") == true
		and _has_exact_keys((contract.get("replacement_contract") as Dictionary), ["source_key", "wall_object_key", "roof_object_key", "actual_supplied_chunk_pair_required", "actual_land_and_area_records_required", "mapped_public_run_indices", "protected_run_indices", "partial_pair_allowed", "fallback_allowed", "generic_stack_allowed", "factory_calls", "raw_source_constructor_callback_required", "tangent_callback_required"])
		and typeof((contract.get("replacement_contract") as Dictionary).get("source_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("source_key") == "w96215651"
		and typeof((contract.get("replacement_contract") as Dictionary).get("wall_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("wall_object_key") == "building:w96215651:wall"
		and typeof((contract.get("replacement_contract") as Dictionary).get("roof_object_key")) == TYPE_STRING and (contract.get("replacement_contract") as Dictionary).get("roof_object_key") == "building:w96215651:roof"
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_supplied_chunk_pair_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("actual_land_and_area_records_required") == false
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("mapped_public_run_indices") as Array), [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21])
		and _int_array_matches(((contract.get("replacement_contract") as Dictionary).get("protected_run_indices") as Array), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 20, 22, 23, 24, 25])
		and typeof((contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("partial_pair_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("fallback_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("fallback_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("generic_stack_allowed") == false
		and typeof((contract.get("replacement_contract") as Dictionary).get("factory_calls")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("replacement_contract") as Dictionary).get("factory_calls"))) and float((contract.get("replacement_contract") as Dictionary).get("factory_calls")) == 1.0
		and typeof((contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("raw_source_constructor_callback_required") == true
		and typeof((contract.get("replacement_contract") as Dictionary).get("tangent_callback_required")) == TYPE_BOOL and (contract.get("replacement_contract") as Dictionary).get("tangent_callback_required") == true
		and _has_exact_keys((contract.get("geometry_contract") as Dictionary), ["source_chunk_sha256", "horizontal_source_footprint_preserved", "original_source_channels_and_roof_preserved", "visual_mesh_instances", "visual_surfaces", "visual_triangles", "wall_native_counts", "roof_native_counts", "world_records", "world_mesh_instances", "world_surfaces", "world_triangles", "world_static_bodies", "world_shapes", "world_topology_scope"])
		and typeof((contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("source_chunk_sha256") == "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5"
		and typeof((contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("horizontal_source_footprint_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved")) == TYPE_BOOL and (contract.get("geometry_contract") as Dictionary).get("original_source_channels_and_roof_preserved") == true
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_mesh_instances")) == 18.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_surfaces")) == 18.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("visual_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("visual_triangles")) == 5104.0
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("wall_native_counts") as Array), [17, 17, 5088, 3, 13])
		and _int_array_matches(((contract.get("geometry_contract") as Dictionary).get("roof_native_counts") as Array), [1, 1, 16, 1, 1])
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_records")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_records"))) and float((contract.get("geometry_contract") as Dictionary).get("world_records")) == 735.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances"))) and float((contract.get("geometry_contract") as Dictionary).get("world_mesh_instances")) == 1159.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_surfaces"))) and float((contract.get("geometry_contract") as Dictionary).get("world_surfaces")) == 1174.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_triangles"))) and float((contract.get("geometry_contract") as Dictionary).get("world_triangles")) == 153873.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies"))) and float((contract.get("geometry_contract") as Dictionary).get("world_static_bodies")) == 484.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_shapes")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("geometry_contract") as Dictionary).get("world_shapes"))) and float((contract.get("geometry_contract") as Dictionary).get("world_shapes")) == 569.0
		and typeof((contract.get("geometry_contract") as Dictionary).get("world_topology_scope")) == TYPE_STRING and (contract.get("geometry_contract") as Dictionary).get("world_topology_scope") == "current_integration_topology"
		and _has_exact_keys((contract.get("ownership_contract") as Dictionary), ["structural_owner_count", "shape_count", "spray_owner_count", "navigation_owner_count", "wall_is_sole_spray_receiver", "original_wall_and_projected_front_are_receivers", "projected_receiver_runs", "projected_receiver_triangles", "projected_receiver_shape_order", "projected_receiver_physics_layer", "projected_receiver_cull_mask", "wall_decal_cull_mask", "wall_shape_order", "roof_shape_order", "added_public_roof_triangles", "original_flat_roof_preserved", "added_public_roof_is_nonreceiver", "all_additions_render_only", "added_ground_collision_triangles", "roof_is_wall_spray_receiver", "roof_world_solid_landing", "eligible_render_layer", "noneligible_render_layer", "terrain_geometry_and_ownership_unchanged"])
		and typeof((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("structural_owner_count")) == 4.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("shape_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("shape_count"))) and float((contract.get("ownership_contract") as Dictionary).get("shape_count")) == 14.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("spray_owner_count")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count"))) and float((contract.get("ownership_contract") as Dictionary).get("navigation_owner_count")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("wall_is_sole_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_wall_and_projected_front_are_receivers")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_wall_and_projected_front_are_receivers") == true
		and _int_array_matches(((contract.get("ownership_contract") as Dictionary).get("projected_receiver_runs") as Array), [10, 11, 12, 13, 14, 16, 17, 18, 19, 21])
		and typeof((contract.get("ownership_contract") as Dictionary).get("projected_receiver_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_triangles")) == 6.0
		and ((contract.get("ownership_contract") as Dictionary).get("projected_receiver_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("projected_receiver_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("projected_receiver_shape_order") as Array)[0] == "ProjectedUpperSiding"
		and typeof((contract.get("ownership_contract") as Dictionary).get("projected_receiver_physics_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_physics_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_physics_layer")) == 5.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("projected_receiver_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("projected_receiver_cull_mask")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask"))) and float((contract.get("ownership_contract") as Dictionary).get("wall_decal_cull_mask")) == 2.0
		and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array).size() == 12
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[0] == "exact_eligible_source_wall"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[1] == "ObservedPublicRoof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[2] == "CarportRoof"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[3] == "CarportPosts"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[4] == "ProjectedUpperClosures"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[5] == "PaleCompleteTrim"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[6] == "BlueOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[7] == "DarkOpaqueGlazing"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[8]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[8] == "BlueGrayClosedDoors"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[9]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[9] == "LocalPrivacyScreens"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[10]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[10] == "PaleDrainageAndFascia"
		and typeof(((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[11]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("wall_shape_order") as Array)[11] == "DoorHardware"
		and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array).size() == 1
		and typeof(((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0]) == TYPE_STRING and ((contract.get("ownership_contract") as Dictionary).get("roof_shape_order") as Array)[0] == "exact_noneligible_source_roof"
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_public_roof_triangles")) == 108.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("original_flat_roof_preserved") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("added_public_roof_is_nonreceiver") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("all_additions_render_only")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("all_additions_render_only") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles"))) and float((contract.get("ownership_contract") as Dictionary).get("added_ground_collision_triangles")) == 0.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_is_wall_spray_receiver") == false
		and typeof((contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("roof_world_solid_landing") == true
		and typeof((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("eligible_render_layer")) == 2.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer"))) and float((contract.get("ownership_contract") as Dictionary).get("noneligible_render_layer")) == 1.0
		and typeof((contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged")) == TYPE_BOOL and (contract.get("ownership_contract") as Dictionary).get("terrain_geometry_and_ownership_unchanged") == true
		and _has_exact_keys((contract.get("truth_boundary") as Dictionary), ["as_built_fidelity_claimed", "interior_modeled", "hidden_schedule_invented", "capture_time_recognition_credit", "capture_time_candidate_promoted", "reference_pixels_packaged", "receiver_complete_inferred_from_art", "game_distinctive_claimed", "unobserved_sides_protected", "unsurveyed_dimensions_and_counts_are_production_inference", "continuous_motion_review_claimed", "ground_to_roof_traversal_claimed", "spray_input_event_dispatch_claimed", "separate_setup_poses_retained", "sparse_movie_samples_only", "raw_door_station_failure_retained", "original_visual_hold_retained", "metadata_only_observer_retained", "unexecuted_central_carport_proposal_retained", "motion_route_scope", "station_held_claimed", "prior_clipped_tag_failure_retained", "scoped_hairline_observation_retained", "native_support_qualification_mm"])
		and typeof((contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("as_built_fidelity_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("interior_modeled")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("interior_modeled") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("hidden_schedule_invented") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_recognition_credit") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("capture_time_candidate_promoted") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("reference_pixels_packaged") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("receiver_complete_inferred_from_art") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("game_distinctive_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unobserved_sides_protected") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unsurveyed_dimensions_and_counts_are_production_inference") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("continuous_motion_review_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("ground_to_roof_traversal_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("spray_input_event_dispatch_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("separate_setup_poses_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("sparse_movie_samples_only") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("raw_door_station_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("original_visual_hold_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("original_visual_hold_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("metadata_only_observer_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("metadata_only_observer_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("unexecuted_central_carport_proposal_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("unexecuted_central_carport_proposal_retained") == true
		and typeof((contract.get("truth_boundary") as Dictionary).get("motion_route_scope")) == TYPE_STRING and (contract.get("truth_boundary") as Dictionary).get("motion_route_scope") == "uncovered_run21"
		and typeof((contract.get("truth_boundary") as Dictionary).get("station_held_claimed")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("station_held_claimed") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("prior_clipped_tag_failure_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained")) == TYPE_BOOL and (contract.get("truth_boundary") as Dictionary).get("scoped_hairline_observation_retained") == false
		and typeof((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) in [TYPE_INT, TYPE_FLOAT] and is_finite(float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm"))) and float((contract.get("truth_boundary") as Dictionary).get("native_support_qualification_mm")) == 4.0,
		"northern_1202_parity_mismatch",
		"1202 exact source, physical detail ownership, historical motion limits or accepted unit bindings drifted.",
	)


func _validate_northern_1202_plan_contract(plan: Dictionary) -> bool:
	var executable_assets := plan.get("executable_assets", []) as Array
	return _require(
		(plan.get("projection_descriptor_ids", []) as Array).is_empty()
		and executable_assets.size() == 3
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/mariner_1202_live_replacement.gd", NORTHERN_1202_ADAPTER_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/mariner_1202_live_factory.gd", NORTHERN_1202_PROTOTYPE_SHA256)
		and _runtime_asset_match(executable_assets, "res://game/scripts/world/facades/site_12_housing_kit.gd", NORTHERN_1202_SITE_KIT_SHA256),
		"northern_1202_parity_mismatch",
		"1202 executable subset must contain exactly the paired adapter, reviewed prototype, and site kit.",
	)
