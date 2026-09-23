extends SceneTree

## Candidate1240 at current31; exact existing accepted records retained.
##1240 remains unregistered and uncredited; frozen study metadata stays historical.
## New target pair/material helpers reuse the successful focused combined contract.
## Mounted editor target dispatch is separate from complete source/signed-release main.
const A1206 := preload("res://game/scripts/world/facades/mariner_1206_live_replacement.gd")
const A1219 := preload("res://game/scripts/world/facades/mariner_1219_live_replacement.gd")
const A1201 := preload("res://game/scripts/world/facades/northern_canopy_free_live_replacement.gd")
const A1238 := preload("res://game/scripts/world/facades/northpoint_1238_live_replacement.gd")
const A1212 := preload("res://game/scripts/world/facades/mariner_1212_live_replacement.gd")
const A1220 := preload("res://game/scripts/world/facades/bayside_1220_live_replacement.gd")
const A1239 := preload("res://game/scripts/world/facades/northpoint_1239_live_replacement.gd")
const A1222 := preload("res://game/scripts/world/facades/bayside_1222_live_replacement.gd")
const A1227 := preload("res://game/scripts/world/facades/northpoint_1227_live_replacement.gd")
const A1234 := preload("res://game/scripts/world/facades/northpoint_1234_live_replacement.gd")
const A1215 := preload("res://game/scripts/world/facades/bayside_1215_live_replacement.gd")
const A1202 := preload("res://game/scripts/world/facades/mariner_1202_live_replacement.gd")
const A1232 := preload("res://game/scripts/world/facades/northpoint_1232_live_replacement.gd")
const A1241 := preload("res://game/scripts/world/facades/northpoint_1241_live_replacement.gd")
const A1221 := preload("res://game/scripts/world/facades/mariner_1221_live_replacement.gd")
const A1240 = preload("res://game/scripts/world/facades/northpoint_1240_live_replacement.gd")
const A1397 := preload("res://game/scripts/world/facades/gateview_1397_live_replacement.gd")
const A1226 := preload("res://game/scripts/world/facades/bayside_1226_live_replacement.gd")
const WORK := "/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-candidate-package-preparation-002"
const ADAPTER := preload("res://game/scripts/world/facades/d2_1444_croaker_quality_v2_live_replacement.gd")
const A1308 := preload("res://game/scripts/world/facades/d5_1308_gateview_live_replacement.gd")
const AM := preload("res://game/scripts/world/facades/maceo_may_live_replacement.gd")
const AFS := preload("res://game/scripts/world/facades/fire_station48_live_replacement.gd")
const A1317 := preload("res://game/scripts/world/facades/d5_1317_gateview_live_replacement.gd")
const A1394 := preload("res://game/scripts/world/facades/d5_1394_gateview_live_replacement.gd")
const PHYSICS_WORLD_SOLID := 1 << 0
const PHYSICS_SPRAY_SURFACE := 1 << 2
const MAIN := "res://game/scenes/main.tscn"
const REGISTRY := "res://game/resources/facades/facade-runtime-registry.json"
const CONTRACTS := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const WORLD := {"bodies":500,"meshes":1287,"rows":735,"shapes":667,"surfaces":1302,"triangles":183761}
const SOURCE_PINS := {
  "res://discovery/facades/facade-recognition-catalog.json": "5380b4eb0f1f0ab40c73f241018062cd55cdbd7678ca9b26bc6858b443460f8e",
  "res://discovery/facades/facade-recognition-catalog.schema.json": "463872dc37f195a4f639a08418e97043c13ba3cbbbda3593883eabd31b81a1bf",
  "res://export_presets.cfg": "490506f5b0842779d66e1088d8fe5b9eb6331f69d5fc40d2d305c0854563f246",
  "res://game/resources/facades/bayside_1215_study.json": "69ec5d8fdf7a9fb93148ae459c5c570726509ea30e10a4193adb2294810b52d8",
  "res://game/resources/facades/bayside_1220_study.json": "984ebbde55fa5dcb1cea8b0d57c20e2773982bbb195e1a52b16dec250ec0735b",
  "res://game/resources/facades/bayside_1222_study.json": "65a67decfd83b376209c8c8f80ab7f456be2006a8a907c2f36211c3e863e0ab2",
  "res://game/resources/facades/d2_1439_chinook_quality_v2_live_replacement.json": "58ba0093d002a3acad06b76876b7333077bb5152827f4a59b0c9b6da132b68d9",
  "res://game/resources/facades/d2_1439_chinook_quality_v2_prototype.json": "1217ae0a101f0f1951a3c12303d11af3aace225745922a09aed276b1958553be",
  "res://game/resources/facades/d2_1444_croaker_quality_v2_live_replacement.json": "472f82f5a3d98b0778aca758ae8277f8b8ba9b4a39875ff54f67781280965135",
  "res://game/resources/facades/d2_1444_croaker_quality_v2_prototype.json": "22efb2fa24ea1db245f8fe204e3f029312da59a7a67644d2f1464f02661046ef",
  "res://game/resources/facades/d5_1308_gateview_live_factory.json": "5fb9d42425df7d6f8b62ffdc3053e88ee559dc0efd0e7880b5e841ed0bf1ac8a",
  "res://game/resources/facades/d5_1308_gateview_live_replacement.json": "c35951faebaa921d41bf0230bf511b3a3fde9b9b1f533272030a5dfb8d8dfe8a",
  "res://game/resources/facades/d5_1308_lawn_tone.gdshader": "d60b1db292234046d2e8fd1a451e0f3f52a69b12afe401e871bedef6067ca7af",
  "res://game/resources/facades/d5_1308_siding_marks.gdshader": "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e",
  "res://game/resources/facades/d5_1317_gateview_live_replacement.json": "d15f6ea9e14ca9723dfd3f5794718fab6ad6d0cbf24091ce0e81fd34821e554f",
  "res://game/resources/facades/d5_1317_gateview_quality_study.json": "33b54fb72cf829e933a0e386e984f6ffe9d9a7c9d335ecb034e779c12bf89a26",
  "res://game/resources/facades/d5_1317_quality_study_geometry.json": "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9",
  "res://game/resources/facades/d5_1317_siding_marks.gdshader": "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e",
  "res://game/resources/facades/d5_1317_surface_tone.gdshader": "2388fbee5821352c30ec5925f4ff159439090c8cb1f4973344a947c65b4e4da0",
  "res://game/resources/facades/d5_1394_gateview_live_factory.json": "2f383cef8b7f141c2a4d30a5f40db45ac166fba4c52539a84a11f7e9cb3b8c86",
  "res://game/resources/facades/d5_1394_gateview_live_replacement.json": "3d74e15f0a438dd4a45f2c778c415879888ef1b7a3cef75ebe7a9682db4de203",
  "res://game/resources/facades/d5_1394_lawn_tone.gdshader": "d60b1db292234046d2e8fd1a451e0f3f52a69b12afe401e871bedef6067ca7af",
  "res://game/resources/facades/d5_1394_siding_marks.gdshader": "1575f777f114d4e00b8e8492b93be6ce35b76070030c589e9b38514d3ff04a7e",
  "res://game/resources/facades/facade-runtime-adapter-contracts.json": "6e76908b51d96afacdd722a0facda82dd43f9a13bea7eb3ddd2dde818eac74aa",
  "res://game/resources/facades/facade-runtime-registry.json": "9247d36589c36c948f28d58f2a72002379906850e5b094e2633129a3cb05e2fc",
  "res://game/resources/facades/fire_station48_live_replacement.json": "4b31025a80909b03b882c089bf17d50dbc6a4ee9d32fa9b072b884fd4eec061a",
  "res://game/resources/facades/fire_station48_quality_study.json": "2ae853642ed360f81ea6dfe53089fa909531af8776f40462fb129076f16b6795",
  "res://game/resources/facades/fire_station48_study_geometry.json": "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597",
  "res://game/resources/facades/fire_station48_upper_cladding.gdshader": "4600d14f6d45455c56ce400cc2b073c124462eee1da0e33f7492b356614f319e",
  "res://game/resources/facades/maceo_may_live_replacement.json": "cf97a1197fdc2c5cea8f5befddcb6f6f75306d9a2b969a6e3297efad0b319c6c",
  "res://game/resources/facades/maceo_may_public_fields.gdshader": "04169ff9212cf35fb50d53dc18791600c5c7647618d8e6c58021bbbc3c724279",
  "res://game/resources/facades/maceo_may_quality_study.json": "11a8784bbb08ea4a6244b1da1dcc8e0c2b589ef66c55a0bd2cc8ff20ad16cd6d",
  "res://game/resources/facades/maceo_may_study_geometry.json": "4caf46d6c3ebb1ef497fbe8012e5f1fd938a055e11a4132c04ed8e6827da12b3",
  "res://game/resources/facades/mariner_1202_study.json": "8490ec8dab6302c9892b37b86542ccc18793dfe309ac7d589fb9dc9cad9ddf22",
  "res://game/resources/facades/mariner_1206_study.json": "5327998befca469042db9ac728de697e56fb311f9f889bb1bc867617425d4f97",
  "res://game/resources/facades/mariner_1212_study.json": "f56009b6ccb5bea7ed63911c7d940573996aad4e1c5ccaa55267adbd150b3066",
  "res://game/resources/facades/mariner_1219_study.json": "5fd7eeb31c4d2cfac52aadff65f1bc7f35458d3e0c8d8469411f75ce032b9f21",
  "res://game/resources/facades/mariner_1221_study_002.json": "512fe3b3bd31ed2abd2ea69713028cb76b6aed782a8d572a700e1d53eee2a833",
  "res://game/resources/facades/northern_canopy_free_study.json": "54659ba6dde676f8a3ea122d654ff9532ffc706c6ea95b0913e4ef10fa5100b0",
  "res://game/resources/facades/northpoint_1227_study.json": "2e8573eb855c110c0d13545d63f8fd467a25a68613d16b91cb1336462baadde7",
  "res://game/resources/facades/northpoint_1232_study_003.json": "609436c6ee4f3f0170ed02b93ada28f927d67401aeb677c03a3dab9d76109f98",
  "res://game/resources/facades/northpoint_1234_study.json": "bb7f2af978cc985491eba694e8e179d39b41f609c594efcc4815a6ee8756d917",
  "res://game/resources/facades/northpoint_1238_study.json": "a7f733e4f67351f9919769ff1329f263efbd43ca0d39a3fb30c3ac77e626c2a9",
  "res://game/resources/facades/northpoint_1239_study.json": "bf1a2073f0d371242d5636dcb47820cb6cbf47f8df9300de7aab95da3cfa6174",
  "res://game/resources/facades/northpoint_1240_study.json": "aebf5005af3e89a2a60db46f38760a9341b1c7a8a6a6216e8777195b37ab42ba",
  "res://game/resources/facades/northpoint_1241_study_002.json": "9ddd9734280fa4380e4eb95d1d0e682300ac55037845f2e73b65dc57de071ccb",
  "res://game/resources/materials/world/batch_06/batch_06_wall_tangent_horizontal_siding_field.gdshader": "cb531c7ee029a3cb8d163a644b2adea885606bab89b688df06828c33d3bc6d9a",
  "res://game/resources/materials/world/site_12_housing/d2_1439_quality_v2_recess_backing.tres": "09928b8617c7ac90e421aa0e61acab916e391c3bac84c486a2e3beda995139fe",
  "res://game/resources/materials/world/site_12_housing/d2_1444_quality_v2_recess_backing.tres": "796b27c2821e62f554232d2b355adb566d96aa3cd5ed8ef7fb765317f190721a",
  "res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres": "75c13aa30a4e3c9f49980d78abe41f40c6c7ab270be6152c201eb8a72ebe8720",
  "res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres": "389c01066767b085ef8ed8ae4c5e1b06062d9ffb135e3e6a7bfa968b963717d7",
  "res://game/resources/materials/world/site_12_housing/site_12_ochre_tan_stucco.tres": "9486ccf52e1f2aff9fc940f60644733d5cf9bf1cb03cebb5332bcc1d7c0aaaf6",
  "res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres": "eddc4900c351dc3a75d163bd380a8b3a39bf6a1c1c3647299e3af19634a60ead",
  "res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres": "d97d7b4a442ffe8ad9a0b003e5c1d6466f9ef9effc7cdb2be8ef966195e66782",
  "res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres": "81fd15832670516b2cc752e89310acda201f30705b01297639703f76f2111a64",
  "res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg": "fa09ed33d59c3bb90ef70d36352207e2e1ca5564cfc61295c0124d1a7d785808",
  "res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_diff_1k.jpg": "ddf9224e9cfa3eb2998d9097e4cd34bd3630c85e0e6798e5a0a000415a684083",
  "res://game/resources/textures/world/polyhaven/clean_asphalt/clean_asphalt_rough_1k.jpg": "2280be133c104eb04370b625ebcc7f6709d2173b43ae2cd15a0074c26f492bf9",
  "res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_diff_1k.jpg": "70d3ff969a7421c7ae057b5d16386d11f5e59c6740db643352e1039413f419c4",
  "res://game/resources/textures/world/polyhaven/concrete_pavement/concrete_pavement_rough_1k.jpg": "99f81099af07b009134b6a81bf0f95ab16da09c57156cc2ed534975664a68533",
  "res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_diff_1k.jpg": "ae94f2b34597b9108eefd88217f55eccaec6d6b382e858a478ee92df90e66617",
  "res://game/resources/textures/world/polyhaven/sparse_grass/sparse_grass_rough_1k.jpg": "9ebe6d03a9551c17d1802835c92c1442acb8f5d38d4874ee8c37770f11c4bed1",
  "res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png": "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c",
  "res://game/scenes/main.tscn": "959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66",
  "res://game/scenes/player/player.tscn": "a37b00ecc620b4f3106a14d1dc9ec22a519f81481e5e6c68252389e13488a793",
  "res://game/scenes/world/world_root.tscn": "ed6dfaa1933cedf2a70ca6afd677a645d588dbf6c823fb04402aaaea4b709ab8",
  "res://game/scripts/interaction/spray_controller.gd": "9897042fbffc6740ebe3eb4c19da544a0d437391ded9987318edc7238c403da4",
  "res://game/scripts/main.gd": "495d61639cf86d6bc89b8fbe7459aab34df24dbc070644271e98bdeb08484b61",
  "res://game/scripts/player/player_camera.gd": "1d53f11cc3d9de00d4bb580aa6322c6f53b0080e5b9e1e3b18baeefd52125cc3",
  "res://game/scripts/player/player_controller.gd": "8b114132d66c78dd0bfd09783c7b9a3a3a441a8b1ae14f33f7308bd9b04ed0ea",
  "res://game/scripts/world/facades/bayside_1215_live_factory.gd": "6613df3605004f128b22bf9f2d3a1a67c8e367c45216557c0c3ab293afb36880",
  "res://game/scripts/world/facades/bayside_1215_live_replacement.gd": "cc6266cc71e9e0243006af8bb6161f061b981ac313b312fea58c4abd3d607c55",
  "res://game/scripts/world/facades/bayside_1220_live_factory.gd": "dcfb622e4f5d2759459e17d1ab465ae9fa772167f335a2d1e0c88a111482273d",
  "res://game/scripts/world/facades/bayside_1220_live_replacement.gd": "1edb75f24c3de6b4c6c780c9bb6b478225925453872e11c76f82fece8a146c38",
  "res://game/scripts/world/facades/bayside_1222_live_factory.gd": "639a5ce1cce22b5635f3bccfe6cb1c7764988662b826f0c25c4183fe2ec787f9",
  "res://game/scripts/world/facades/bayside_1222_live_replacement.gd": "a4f6e7242dd4130b3dca67cad165a8a3067129ab2a7455e4e0f0f76ef3c144bf",
  "res://game/scripts/world/facades/d2_1439_chinook_quality_v2_live_replacement.gd": "d5a4458be7a5c2fb6989f9d8a343d497d2f144eb19c445de6016888e7b3cce5e",
  "res://game/scripts/world/facades/d2_1439_chinook_quality_v2_prototype.gd": "797dfb3075dacdf24a32b4ee0fa4959c296b35ae2d51f2d3c4dbba407fead3b7",
  "res://game/scripts/world/facades/d2_1444_croaker_quality_v2_live_replacement.gd": "178cc9df2c7add966a95427099b3a9900fde459e5bfc4825211e06c119cc2e32",
  "res://game/scripts/world/facades/d2_1444_croaker_quality_v2_prototype.gd": "afe74e5254af720cd855fb8dbadcb71a283d0c8b2d0f79c9565dd2e62b6e9d42",
  "res://game/scripts/world/facades/d5_1308_gateview_live_factory.gd": "6950aab112f73fdf78c1cad2f3deca72ac7e46b2a07faffe04f82987a1e07498",
  "res://game/scripts/world/facades/d5_1308_gateview_live_replacement.gd": "3faca37243c2ee51ff1d2834b3d581d4b7d4552a45179224371a2570b7f08ad5",
  "res://game/scripts/world/facades/d5_1317_gateview_live_factory.gd": "80930edee46371825bfb7b337b94bdbb4e3b7fc064aa2ba3061b6a86886af884",
  "res://game/scripts/world/facades/d5_1317_gateview_live_replacement.gd": "283a020492c03fde62c591ea9ebcb1e5c5403a55aca514f0998908b440d9e819",
  "res://game/scripts/world/facades/d5_1394_gateview_live_factory.gd": "25284afdd779f6b491da47218fc6fdd169dad3bb3c56da70d76680cc91781fcb",
  "res://game/scripts/world/facades/d5_1394_gateview_live_replacement.gd": "42e0233cdbe1be7bdcbb63603c1bb2cae4c247dde87a51f9518cc1afafc82076",
  "res://game/scripts/world/facades/facade_runtime_registry_loader.gd": "ad5ffd28dcd19653c9d32f05e7e4cc33795656db5266042d511309ae77bf32be",
  "res://game/scripts/world/facades/fire_station48_live_factory.gd": "33c945be3699fe7f94874d7a65ff0d01963092d0c0cb85deacaf4f794d9996d5",
  "res://game/scripts/world/facades/fire_station48_live_replacement.gd": "163db6f19bb7368f5aa271282c11d4028337d48cc1b2e3d37b8231e1c329d25a",
  "res://game/scripts/world/facades/maceo_may_live_factory.gd": "bb47a10d3464f162516ece9ac0591bdead1791e847b89eff35fd3f59adc56c85",
  "res://game/scripts/world/facades/maceo_may_live_replacement.gd": "d9ad456c2d11437a0cf70277c7fab383359c49d6ab34ed698ec316ea97668001",
  "res://game/scripts/world/facades/mariner_1202_live_factory.gd": "c81cf174af5f91a21dc95306b77296d8d82152a54ef301e87853944b3b78c59c",
  "res://game/scripts/world/facades/mariner_1202_live_replacement.gd": "29f17b796ae922d967e87212f7e3ed21fa30db7d9ce4b9c2c7a2ba079e847a70",
  "res://game/scripts/world/facades/mariner_1206_live_factory.gd": "906922118fd881a5668962c87964b8c46db32d92a5483fd072a4c2a90b521c56",
  "res://game/scripts/world/facades/mariner_1206_live_replacement.gd": "88e0858a2b9d3559c8d2e766874f93cd44335f89c232e8115ef7c7f97ecc951b",
  "res://game/scripts/world/facades/mariner_1212_live_factory.gd": "0594ea7a6e1f09a918349ee5af58722896e3b300ae640d8c1d4025b8219bc2a9",
  "res://game/scripts/world/facades/mariner_1212_live_replacement.gd": "c0941706e3cee909b260e278a07d846932b805aaeb5e12440463e43678b3513c",
  "res://game/scripts/world/facades/mariner_1219_live_factory.gd": "216e83f6ee69313d77ef5c2007720a126e07cff5e30ce23401a1d28cdac84748",
  "res://game/scripts/world/facades/mariner_1219_live_replacement.gd": "c6a0c16cc762d33c62c3f3885d865999be5e65e148f56a66e9da348e6cbfb58a",
  "res://game/scripts/world/facades/mariner_1221_live_factory.gd": "0347c885b48e02e376afbbdb7bf5d07ff6aa32c4b11de4521427c85daaa486ac",
  "res://game/scripts/world/facades/mariner_1221_live_replacement.gd": "15816708f9b6b8f15ae83f5d5d0ec0823165fbc0a2db51bdaeba442c34004b1e",
  "res://game/scripts/world/facades/northern_canopy_free_live_factory.gd": "2a01cf9fe20d81b381e445e3531377a2802082f69424445196ede570d15b2f96",
  "res://game/scripts/world/facades/northern_canopy_free_live_replacement.gd": "8967229a37be5401962132b846b08f1f527fb27f6aae3cd2d6d97eb70f608b82",
  "res://game/scripts/world/facades/northpoint_1227_live_factory.gd": "6492b8e48226ed09c7e7171bd7fd51e25b8e347c38d87d2d0931b2b3337fb2f4",
  "res://game/scripts/world/facades/northpoint_1227_live_replacement.gd": "ace49917dc8935c75124e70f3dc573330a2236a6a82ef948b41b1eeeee451c6e",
  "res://game/scripts/world/facades/northpoint_1232_live_factory.gd": "05a93c31bbdfe0e9bf06530e02a33f49826f3af573e4128eaaa8d127cd686910",
  "res://game/scripts/world/facades/northpoint_1232_live_replacement.gd": "eab24f028a8956a00d415fb058c84a2be84b86f53f3ce357122b48441f9ec27e",
  "res://game/scripts/world/facades/northpoint_1234_live_factory.gd": "75b93b31c6b6bbad59ee32cd0373d96b638212370281c055b37909c43fb38ae8",
  "res://game/scripts/world/facades/northpoint_1234_live_replacement.gd": "6bf227c87c36c2ff02b883bf6224bb35d281f098e76035cc8d64e5ac25bfbbdc",
  "res://game/scripts/world/facades/northpoint_1238_live_factory.gd": "2046c934f4fdaa35f12c7e343910b26a7e1cb2d7e489adc22467bcd1b41bb45f",
  "res://game/scripts/world/facades/northpoint_1238_live_replacement.gd": "fef8305341da71b88c1fa90a5ccdd9bba98afc10f999de7208cc6373ff7ba9c3",
  "res://game/scripts/world/facades/northpoint_1239_live_factory.gd": "3573433b35a317f40f908c64ef05519559918f5ccca0f9af14849af2b932732d",
  "res://game/scripts/world/facades/northpoint_1239_live_replacement.gd": "e397a0879a8beb8eca7e8ec32e80c40652cfb1b5b67a50bf6f52952f4ae44aa5",
  "res://game/scripts/world/facades/northpoint_1240_live_factory.gd": "8e34fe18e29158a883fa258a927420676c6be1cbb2748ef4a443299a7afed476",
  "res://game/scripts/world/facades/northpoint_1240_live_replacement.gd": "a2c7536488783593e48a5a91641fcc5bf11df490e830beaa61c3d1b7e7cc8b48",
  "res://game/scripts/world/facades/northpoint_1241_live_factory.gd": "cf94d080e386e5abcffb00328571965cc52a96e6c1522d356a6b2248e18d9bc0",
  "res://game/scripts/world/facades/northpoint_1241_live_replacement.gd": "1e1cebbd652e2409723c7000398a78aecedf9f4c77624016c5fb9070ffe70c6c",
  "res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
  "res://game/scripts/world/world_chunk_builder.gd": "a89a31212fcd181350ab5090e86df7140d8246077871cfae3b69a8c835539e54",
  "res://game/scripts/world/world_loader.gd": "0bfb5c64ede051dadd87da10e85518a2c22c63d36ff9387e8221bdd0c24287af",
  "res://generated/world/chunks/x_-1__z_-4.json": "bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac",
  "res://generated/world/chunks/x_-1__z_1.json": "b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c",
  "res://generated/world/chunks/x_-2__z_-1.json": "6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2",
  "res://generated/world/chunks/x_-2__z_-3.json": "7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5",
  "res://generated/world/chunks/x_-2__z_-4.json": "932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4",
  "res://generated/world/chunks/x_-2__z_0.json": "3e7d1cb020d4a8f8a2852121a181a1e2d441fee40de42d744d37fbbcba59168b",
  "res://generated/world/chunks/x_-3__z_-2.json": "35bf23d64e860d39c5b79a98be7830f4f477143f7e9490c6739dec0627062d11",
  "res://generated/world/chunks/x_0__z_-2.json": "c0e1f86787410d975ad90272482e5f4971c4aedc7eb83132cd28b22acf1a3456",
  "res://generated/world/manifest.json": "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3",
  "res://project.godot": "305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af",
  "res://tools/build_facade_recognition_registry.mjs": "9958ab36ed20eb6b209e320e153df09bd0c725e660d24546b09f298bd7bc02ef",
  "res://game/scripts/world/facades/gateview_1397_live_factory.gd": "ce6223bf527c74431dc794bfc9ab7211feabd881e9d080e318a2f712547e4a91",
  "res://game/scripts/world/facades/gateview_1397_live_replacement.gd": "a906e841e11ad3c421abe208ef19b4ba3f4fb3e1e2c9ef563d609dd565d5fd77",
  "res://game/resources/facades/gateview_1397_study.json": "97919d0168bab83ff0f7118cf00fb0bbea1eb062c731d2b956de896a1330616a",
  "res://game/scripts/world/facades/bayside_1226_live_factory.gd": "7060cf8a32b12781be8ed52f7056680af838f6d4930fb88a782901db98bef62e",
  "res://game/scripts/world/facades/bayside_1226_live_replacement.gd": "d26993a5443fdf4b30477c9f47e96fdc54fdc1f517c5dbaaeb14d3f8b2120c66",
  "res://game/resources/facades/bayside_1226_study.json": "34fb34bec3fa672277fa081dec042ecf1ee4597f293690a6588f85460ff59da2"
}
const EXCLUDED := [
  "res://game/scripts/world/facades/fire_station48_quality_study.gd",
  "res://game/scripts/world/facades/fire_station48_quality_study.gd.uid",
  "res://game/scenes/world/facades/site_12_housing/d2_1439_chinook_standalone_hero_prototype.tscn",
  "res://game/tests/d2_1439_chinook_standalone_hero_capture.gd",
  "res://game/tests/d2_1439_chinook_standalone_hero_capture.gd.uid",
  "res://game/tests/headless_d2_1439_chinook_standalone_hero_contract.gd",
  "res://game/tests/headless_d2_1439_chinook_standalone_hero_contract.gd.uid",
  "res://game/tests/headless_d2_1439_chinook_standalone_hero_evidence_contract.gd",
  "res://game/tests/headless_d2_1439_chinook_standalone_hero_evidence_contract.gd.uid",
  "res://game/tests/headless_d2_1439_chinook_standalone_hero_package_contract.gd",
  "res://game/tests/headless_d2_1439_chinook_standalone_hero_package_contract.gd.uid",
  "res://game/scenes/world/facades/site_12_housing/d2_1444_croaker_standalone_hero_prototype.tscn",
  "res://game/tests/d2_1444_croaker_standalone_hero_capture.gd",
  "res://game/tests/d2_1444_croaker_standalone_hero_capture.gd.uid",
  "res://game/tests/headless_d2_1444_croaker_standalone_hero_contract.gd",
  "res://game/tests/headless_d2_1444_croaker_standalone_hero_contract.gd.uid",
  "res://game/tests/headless_d2_1444_croaker_standalone_hero_evidence_contract.gd",
  "res://game/tests/headless_d2_1444_croaker_standalone_hero_evidence_contract.gd.uid",
  "res://game/tests/headless_d2_1444_croaker_standalone_hero_package_contract.gd",
  "res://game/tests/headless_d2_1444_croaker_standalone_hero_package_contract.gd.uid"
]
var _failed := false
var _measured_world: Dictionary = {}
var _gameplay_activation_observation: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var mounted := FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot")
	var arguments := OS.get_cmdline_user_args()
	if mounted:
		_require(arguments.size() == 2 and arguments[0].begins_with("--pck=") and arguments[1].begins_with("--pck-sha256="), "Mounted gate requires exact PCK path/hash.")
		if not _failed:
			var path := arguments[0].trim_prefix("--pck=")
			var sha := arguments[1].trim_prefix("--pck-sha256=")
			_require(path.is_absolute_path() and sha.length() == 64 and FileAccess.file_exists(path) and FileAccess.get_sha256(path) == sha, "Mounted PCK identity mismatch.")
		for path: String in EXCLUDED:
			_require(not _exists_with_remaps(path), "Mounted standalone activation remains: " + path)
		for path: String in ["res://discovery/", "res://evidence/", "res://source_assets/", "res://tools/", "res://build/"]:
			_require(not DirAccess.dir_exists_absolute(path), "Private directory remains: " + path)
	else:
		_require(arguments.is_empty(), "Source gate received mount arguments.")
		for path: String in SOURCE_PINS:
			_require(FileAccess.get_sha256(path) == str(SOURCE_PINS[path]), "Source pin drift: " + path)
		_require(ADAPTER.source_dependency_hashes_match() and A1308.source_dependency_hashes_match() and A1394.source_dependency_hashes_match() and A1317.source_dependency_hashes_match() and AFS.source_dependency_hashes_match() and AM.source_dependency_hashes_match(), "Source dependency hash drift.")
		_require(A1206.source_dependency_hashes_match() and A1219.source_dependency_hashes_match(), "Mariner exact source factory/config hashes.")
		_require(A1212.source_dependency_hashes_match() and A1220.source_dependency_hashes_match() and A1239.source_dependency_hashes_match(), "Three candidate exact source factory/config hashes.")
		_require(A1222.source_dependency_hashes_match() and A1227.source_dependency_hashes_match() and A1202.source_dependency_hashes_match(), "Three new candidate exact factory/config hashes.")
		_require(A1234.source_dependency_hashes_match() and A1215.source_dependency_hashes_match(), "Two candidate exact factory/config hashes.")
		_require(A1201.source_dependency_hashes_match() and A1238.source_dependency_hashes_match(), "Northern exact source factory/config hashes.")
		_require(A1232.source_dependency_hashes_match(), "Exact new target factory/config: 1232")
		_require(A1241.source_dependency_hashes_match(), "Exact new target factory/config: 1241")
		_require(A1221.source_dependency_hashes_match(), "Retained1221 factory/config")
		_require(A1240.source_dependency_hashes_match(), "Exact new1240 factory/config")
		_require(A1226.source_dependency_hashes_match(), "Exact candidate1226 factory/config")
		_require(A1397.source_dependency_hashes_match(), "Exact candidate1397 factory/config")
		var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
		for path: String in EXCLUDED:
			_require(path.trim_prefix("res://") in preset, "Preset omits activation exclusion: " + path)
	_require(A1206.runtime_dependency_closure_exists() and A1219.runtime_dependency_closure_exists(), "Mariner remap-aware runtime factory/config closure.")
	_require(A1212.runtime_dependency_closure_exists() and A1220.runtime_dependency_closure_exists() and A1239.runtime_dependency_closure_exists(), "Three candidate remap-aware runtime factory/config closures.")
	_require(A1222.runtime_dependency_closure_exists() and A1227.runtime_dependency_closure_exists() and A1202.runtime_dependency_closure_exists(), "Three new candidate remap-aware runtime factory/config closures.")
	_require(A1234.runtime_dependency_closure_exists() and A1215.runtime_dependency_closure_exists(), "Two candidate remap-aware runtime closures.")
	_require(A1201.runtime_dependency_closure_exists() and A1238.runtime_dependency_closure_exists(), "Northern remap-aware runtime factory/config closure.")
	_require(A1232.runtime_dependency_closure_exists(), "New target remap closure: 1232")
	_require(A1241.runtime_dependency_closure_exists(), "New target remap closure: 1241")
	_require(A1221.runtime_dependency_closure_exists(), "Retained1221 closure")
	_require(A1240.runtime_dependency_closure_exists(), "New1240 remap closure")
	_require(A1226.runtime_dependency_closure_exists(), "Candidate1226 remap closure")
	_require(A1397.runtime_dependency_closure_exists(), "Candidate1397 remap closure")
	_require(not _exists_with_remaps("res://override.cfg"), "Capture override remains.")
	for path: String in ["res://game/scripts/world/facades/maceo_may_quality_study.gd", "res://game/scripts/world/facades/maceo_may_quality_study.gd.uid"]:
		_require(not _exists_with_remaps(path), "Historical Maceo study activation remains: " + path)
	_require(ADAPTER.runtime_dependency_closure_exists() and A1308.runtime_dependency_closure_exists() and A1394.runtime_dependency_closure_exists() and A1317.runtime_dependency_closure_exists() and AFS.runtime_dependency_closure_exists() and AM.runtime_dependency_closure_exists(), "Runtime closure incomplete.")
	for path: String in SOURCE_PINS:
		if not path.begins_with("res://game/") and not path.begins_with("res://generated/"):
			continue
		_require(_exists_with_remaps(path), "Runtime resource absent: " + path)
		if path.get_extension() == "json":
			_require(FileAccess.get_sha256(path) == str(SOURCE_PINS[path]), "Mounted raw JSON drift: " + path)
		else:
			_require(ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) != null, "Runtime resource not remap-loadable: " + path)
	_require(str(ProjectSettings.get_setting("application/run/main_scene", "")) == MAIN, "Ordinary main project setting changed.")
	var registry := _json(REGISTRY)
	var contracts := _json(CONTRACTS)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	_require(str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/32" and str(contracts.get("schema_version", "")) == "ti.facade-runtime-adapter-contracts/31", "Authority schemas drift.")
	_require((metric.get("accepted_physical_unit_ids", []) as Array).size()==32 and (registry.get("units", []) as Array).size()==213 and (registry.get("active_runtime_adapters", []) as Array).size()==31 and (contracts.get("plans", []) as Array).size()==40 and int((contracts.get("counts", {}) as Dictionary).get("package_safe_adapter_receivers", -1))==34 and int((contracts.get("counts", {}) as Dictionary).get("disabled_adapter_receivers", -1))==6 and int((contracts.get("counts", {}) as Dictionary).get("disabled_projection_occurrences", -1))==13 and (registry.get("legacy_adapters", []) as Array).size()==9, "Eight consumed current32 scalars")
	# Current authority is distinct from frozen adapter capture-time9/213 metadata below.
	_require(metric == JSON.parse_string("{\"accepted_physical_unit_ids\":[\"physical-building:r16681702\",\"physical-building:r19685981\",\"physical-building:w1222720021\",\"physical-building:w1249412093\",\"physical-building:w1249412094\",\"physical-building:w291189336\",\"physical-building:w34313540\",\"physical-building:w34313545\",\"physical-building:w764313741\",\"physical-building:w95934105\",\"physical-building:w95934117\",\"physical-building:w95934119\",\"physical-building:w95934123\",\"physical-building:w95934125\",\"physical-building:w95934144\",\"physical-building:w96215646\",\"physical-building:w96215649\",\"physical-building:w96215651\",\"physical-building:w96215652\",\"physical-building:w96215653\",\"physical-building:w96215658\",\"physical-building:w96215659\",\"physical-building:w96215661\",\"physical-building:w96215666\",\"physical-building:w96215669\",\"physical-building:w96215672\",\"physical-building:w96215673\",\"physical-building:w96215674\",\"physical-building:w96215677\",\"physical-building:w96215680\",\"physical-building:w96215682\",\"physical-building:w96215688\"],\"denominator\":213,\"denominator_kind\":\"immutable_physical_recognition_units\",\"display\":\"32/213\",\"isle_house_non_numerator_source_keys\":[\"w1282547786\",\"w1282547787\"],\"numerator\":32,\"rollup_policy\":\"one_claim_per_physical_recognition_unit\"}"), "Exact32 metric and accepted physical identities")
	_require((registry.get("active_runtime_adapters",[]) as Array).size()==31 and (contracts.get("plans",[]) as Array).size()==40 and int((contracts.get("counts",{}) as Dictionary).get("package_safe_adapter_receivers",-1))==34,"Current adapter/plan counts")
	_require(str((registry.get("build_contract", {}) as Dictionary).get("compiler_version", "")) == "1.31.0" and str((contracts.get("build_contract", {}) as Dictionary).get("compiler_version", "")) == "1.31.0" and str((contracts.get("loader_contract", {}) as Dictionary).get("api_version", "")) == "ti.facade-runtime-registry-loader/31", "Current compiler/loader version drifted.")
	if not _failed:
		_mounted_northern(A1201, 10)
		_mounted_northern(A1238, 16)
		_mounted_mariner(A1206)
		_mounted_mariner(A1219)
		for adapter: Script in [A1212, A1220, A1239]: _mounted_family(adapter)
		for adapter: Script in [A1222, A1227, A1202, A1234, A1215, A1232, A1241, A1221, A1240, A1397, A1226]: _mounted_projected_family(adapter)
	if not _failed:
		if mounted:
			_mounted_component()
			_mounted_new_pair(A1308)
			_mounted_new_pair(A1394)
			_mounted_new_pair(A1317)
			_mounted_station48()
			_mounted_maceo()
		else:
			await _ordinary_main()
	if not _failed:
		print("PASS: Current32Families1212+1220+1239+Mariner1206+1219+Northern1201+1238+Maceo+Station48+1308+1394+1317 %s package contract; target components exact; source ordinary-main735/1287/1302/183761/500/667, current_authority=32/213; historical1444capture9/213 remains separate; this_check_grants_credit=false" % ("mounted" if mounted else "source"))
	if not mounted:
		var result := {"ok": not _failed, "measured_world": _measured_world, "gameplay_activation_observation": _gameplay_activation_observation, "authority": "32/213", "recognition_credit": 0, "scope": "Current32 exact source/remap and accepted1240 attachment; historical role/app evidence remains unchanged. Original independent V art equivalence and unit mechanics/visual reviews remain separately bound."}
		var file := FileAccess.open(WORK + "/source-component-001-result.json", FileAccess.WRITE)
		file.store_string(JSON.stringify(result, "\t") + "\n")
	quit(1 if _failed else 0)

func _ordinary_main() -> void:
	var packed := load(MAIN) as PackedScene
	_require(packed != null, "Main scene failed to load.")
	if _failed:
		return
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var ready: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, keys: Array) -> void: failures.append({"code": code, "message": message, "keys": keys}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await process_frame
	for startup_frame in 120:
		if player.visible or not failures.is_empty():
			break
		await physics_frame
	var e := world.get_runtime_evidence()
	var actual := {"rows": e.playable_rows, "meshes": e.mesh_instances, "surfaces": e.surfaces, "triangles": e.triangles, "bodies": e.static_bodies, "shapes": e.shapes}
	_measured_world = actual.duplicate(true)
	_require(failures.is_empty() and ready.size() == 1 and world.is_world_validated() and actual == WORLD, "Ordinary world mismatch: %s / %s" % [actual, failures])
	_require(player.visible and player.is_physics_processing() and player.was_first_reveal_grounded() and player.is_on_floor(), "Ordinary player did not reveal grounded.")
	var observation_started_usec := Time.get_ticks_usec()
	var node_transform := player.global_transform
	var server_transform: Transform3D = PhysicsServer3D.body_get_state(player.get_rid(), PhysicsServer3D.BODY_STATE_TRANSFORM)
	_gameplay_activation_observation = {"boundary":"existing ordinary-main grounded reveal", "tree_paused":paused, "player_can_process":player.can_process(), "player_physics_processing":player.is_physics_processing(), "player_process_mode":player.process_mode, "physics_frame":Engine.get_physics_frames(), "process_frame":Engine.get_process_frames(), "inside_physics_frame":Engine.is_in_physics_frame(), "node_transform":str(node_transform), "server_transform":str(server_transform), "node_transform_bytes":var_to_bytes(node_transform).hex_encode(), "server_transform_bytes":var_to_bytes(server_transform).hex_encode(), "started_usec":observation_started_usec, "finished_usec":Time.get_ticks_usec(), "scope":"Synchronous observations only; no pause/controller mutation, extra wait or movement; no cross-frame equality acceptance gate."}
	print("CANDIDATE1240_GAMEPLAY_ACTIVATION: " + JSON.stringify(_gameplay_activation_observation))
	var walls := _record_roots(world, ADAPTER.WALL_KEY)
	var roofs := _record_roots(world, ADAPTER.ROOF_KEY)
	_require(walls.size() == 1 and roofs.size() == 1, "1444 ordinary attachment is not one atomic wall/roof pair.")
	if walls.size() == 1 and roofs.size() == 1:
		_require(_live_node_contract_matches(walls[0], roofs[0], {}), "1444 actual live geometry/collision/material/metadata contract failed.")
		print("D2_1444_PACKAGE_ATTACHMENT: wall=%s roof=%s wall_counts=%s roof_counts=%s geometry=%s ownership=%s" % [walls[0].get_path(), roofs[0].get_path(), _measure(walls[0]), _measure(roofs[0]), ADAPTER.EXPECTED_GEOMETRY_SIGNATURE, ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE])
	_require(main._mac_export_1439_attachment_valid(), "Source ordinary main preserves accepted 1439 paired attachment.")
	_require(main._mac_export_1444_attachment_valid(), "Source ordinary main preserves accepted1444paired attachment.")
	_require(main._mac_export_1308_attachment_valid() and main._mac_export_1394_attachment_valid() and main._mac_export_1317_attachment_valid(), "Source ordinary main requires both exact new pair smoke predicates.")
	_require(main._mac_export_fire_station48_attachment_valid(), "Actual ordinary Station48 attachment predicate.")
	var fs_walls := _record_roots(world, AFS.WALL_KEY)
	var fs_roofs := _record_roots(world, AFS.ROOF_KEY)
	_require(fs_walls.size() == 1 and fs_roofs.size() == 1, "One ordinary Station48 pair.")
	if fs_walls.size() == 1 and fs_roofs.size() == 1: _validate_station48(fs_walls[0], fs_roofs[0])
	_require(main._mac_export_maceo_may_attachment_valid(), "Actual ordinary Maceo attachment predicate.")
	var mm_walls := _record_roots(world, AM.WALL_KEY)
	var mm_roofs := _record_roots(world, AM.ROOF_KEY)
	_require(mm_walls.size() == 1 and mm_roofs.size() == 1, "One ordinary Maceo pair.")
	if mm_walls.size() == 1 and mm_roofs.size() == 1: _validate_maceo(mm_walls[0], mm_roofs[0])
	for adapter: Script in [A1308, A1394, A1317]:
		var new_walls := _record_roots(world, adapter.WALL_KEY)
		var new_roofs := _record_roots(world, adapter.ROOF_KEY)
		_require(new_walls.size() == 1 and new_roofs.size() == 1, "One actual new pair " + adapter.SOURCE_KEY)
		if new_walls.size() == 1 and new_roofs.size() == 1:
			_validate_new_pair(new_walls[0], new_roofs[0], adapter)
	_require(main._mac_export_1201_attachment_valid() and main._mac_export_1238_attachment_valid(), "Both actual northern ordinary-main attachment predicates.")
	for spec: Array in [[A1201, 10], [A1238, 16]]:
		var adapter: Script = spec[0]
		var nw := _northern_roots(world, adapter, adapter.WALL_KEY)
		var nr := _northern_roots(world, adapter, adapter.ROOF_KEY)
		_require(nw.size() == 1 and nr.size() == 1, "Northern actual outer attachment roots: " + adapter.SOURCE_KEY)
		if nw.size() == 1 and nr.size() == 1: _validate_northern(nw[0], nr[0], adapter, int(spec[1]))
	_require(main._mac_export_1206_attachment_valid() and main._mac_export_1219_attachment_valid(), "Both actual Mariner ordinary-main attachment predicates.")
	for adapter: Script in [A1206, A1219]:
		var mw := _northern_roots(world, adapter, adapter.WALL_KEY)
		var mr := _northern_roots(world, adapter, adapter.ROOF_KEY)
		_require(mw.size() == 1 and mr.size() == 1, "Mariner actual outer attachment roots: " + adapter.SOURCE_KEY)
		if mw.size() == 1 and mr.size() == 1: _validate_mariner(mw[0], mr[0], adapter)
	_require(main._mac_export_1212_attachment_valid() and main._mac_export_1220_attachment_valid() and main._mac_export_1239_attachment_valid(), "All three actual candidate ordinary-main predicates.")
	_require(main._mac_export_projected_family_attachment_valid(A1222, "1222"), "Actual 1222 ordinary-main projected pair predicate.")
	var projected_1222_walls := _northern_roots(world, A1222, A1222.WALL_KEY)
	var projected_1222_roofs := _northern_roots(world, A1222, A1222.ROOF_KEY)
	_require(projected_1222_walls.size() == 1 and projected_1222_roofs.size() == 1, "One ordinary 1222 pair.")
	if projected_1222_walls.size() == 1 and projected_1222_roofs.size() == 1: _validate_projected_family(projected_1222_walls[0], projected_1222_roofs[0], A1222)
	_require(main._mac_export_projected_family_attachment_valid(A1227, "1227"), "Actual 1227 ordinary-main projected pair predicate.")
	var projected_1227_walls := _northern_roots(world, A1227, A1227.WALL_KEY)
	var projected_1227_roofs := _northern_roots(world, A1227, A1227.ROOF_KEY)
	_require(projected_1227_walls.size() == 1 and projected_1227_roofs.size() == 1, "One ordinary 1227 pair.")
	if projected_1227_walls.size() == 1 and projected_1227_roofs.size() == 1: _validate_projected_family(projected_1227_walls[0], projected_1227_roofs[0], A1227)
	_require(main._mac_export_projected_family_attachment_valid(A1202, "1202"), "Actual 1202 ordinary-main projected pair predicate.")
	var projected_1202_walls := _northern_roots(world, A1202, A1202.WALL_KEY)
	var projected_1202_roofs := _northern_roots(world, A1202, A1202.ROOF_KEY)
	_require(projected_1202_walls.size() == 1 and projected_1202_roofs.size() == 1, "One ordinary 1202 pair.")
	if projected_1202_walls.size() == 1 and projected_1202_roofs.size() == 1: _validate_projected_family(projected_1202_walls[0], projected_1202_roofs[0], A1202)
	_require(main._mac_export_projected_family_attachment_valid(A1234, "1234"), "Actual 1234 ordinary-main projected pair predicate.")
	var projected_1234_walls := _northern_roots(world, A1234, A1234.WALL_KEY)
	var projected_1234_roofs := _northern_roots(world, A1234, A1234.ROOF_KEY)
	_require(projected_1234_walls.size() == 1 and projected_1234_roofs.size() == 1, "One ordinary 1234 pair.")
	if projected_1234_walls.size() == 1 and projected_1234_roofs.size() == 1: _validate_projected_family(projected_1234_walls[0], projected_1234_roofs[0], A1234)
	_require(main._mac_export_projected_family_attachment_valid(A1215, "1215"), "Actual 1215 ordinary-main projected pair predicate.")
	var projected_1215_walls := _northern_roots(world, A1215, A1215.WALL_KEY)
	var projected_1215_roofs := _northern_roots(world, A1215, A1215.ROOF_KEY)
	_require(projected_1215_walls.size() == 1 and projected_1215_roofs.size() == 1, "One ordinary 1215 pair.")
	if projected_1215_walls.size() == 1 and projected_1215_roofs.size() == 1: _validate_projected_family(projected_1215_walls[0], projected_1215_roofs[0], A1215)
	for adapter: Script in [A1212, A1220, A1239]:
		var fw := _northern_roots(world, adapter, adapter.WALL_KEY)
		var fr := _northern_roots(world, adapter, adapter.ROOF_KEY)
		_require(fw.size() == 1 and fr.size() == 1, "One candidate outer attachment pair: " + adapter.SOURCE_KEY)
		if fw.size() == 1 and fr.size() == 1: _validate_family(fw[0], fr[0], adapter)
	_require(main._mac_export_projected_family_attachment_valid(A1232, "1232"), "Actual 1232 ordinary-main pair predicate.")
	var target_1232_walls := _northern_roots(world, A1232, A1232.WALL_KEY)
	var target_1232_roofs := _northern_roots(world, A1232, A1232.ROOF_KEY)
	_require(target_1232_walls.size() == 1 and target_1232_roofs.size() == 1, "One ordinary 1232 pair.")
	if target_1232_walls.size() == 1 and target_1232_roofs.size() == 1: _validate_projected_family(target_1232_walls[0], target_1232_roofs[0], A1232)
	_require(main._mac_export_projected_family_attachment_valid(A1241, "1241"), "Actual 1241 ordinary-main pair predicate.")
	var target_1241_walls := _northern_roots(world, A1241, A1241.WALL_KEY)
	var target_1241_roofs := _northern_roots(world, A1241, A1241.ROOF_KEY)
	_require(target_1241_walls.size() == 1 and target_1241_roofs.size() == 1, "One ordinary 1241 pair.")
	if target_1241_walls.size() == 1 and target_1241_roofs.size() == 1: _validate_projected_family(target_1241_walls[0], target_1241_roofs[0], A1241)
	_require(main._mac_export_projected_family_attachment_valid(A1221, "1221"), "Actual 1221 ordinary-main pair predicate.")
	var target_1221_walls := _northern_roots(world, A1221, A1221.WALL_KEY)
	var target_1221_roofs := _northern_roots(world, A1221, A1221.ROOF_KEY)
	_require(target_1221_walls.size() == 1 and target_1221_roofs.size() == 1, "One ordinary 1221 pair.")
	if target_1221_walls.size() == 1 and target_1221_roofs.size() == 1: _validate_projected_family(target_1221_walls[0], target_1221_roofs[0], A1221)
	_require(main._mac_export_projected_family_attachment_valid(A1240, "1240"), "Actual1240 ordinary-main pair predicate.")
	var target_1240_walls := _northern_roots(world, A1240, A1240.WALL_KEY)
	var target_1240_roofs := _northern_roots(world, A1240, A1240.ROOF_KEY)
	_require(target_1240_walls.size() == 1 and target_1240_roofs.size() == 1, "One ordinary1240 pair.")
	if target_1240_walls.size() == 1 and target_1240_roofs.size() == 1: _validate_projected_family(target_1240_walls[0], target_1240_roofs[0], A1240)
	_require(main._mac_export_projected_family_attachment_valid(A1397, "1397"), "Actual1397 ordinary-main pair predicate.")
	var target_1397_walls := _northern_roots(world, A1397, A1397.WALL_KEY)
	var target_1397_roofs := _northern_roots(world, A1397, A1397.ROOF_KEY)
	_require(target_1397_walls.size() == 1 and target_1397_roofs.size() == 1, "One ordinary1397 pair.")
	if target_1397_walls.size() == 1 and target_1397_roofs.size() == 1: _validate_projected_family(target_1397_walls[0], target_1397_roofs[0], A1397)
	_require(main._mac_export_projected_family_attachment_valid(A1226, "1226"), "Actual1226 ordinary-main pair predicate.")
	var target_1226_walls := _northern_roots(world, A1226, A1226.WALL_KEY)
	var target_1226_roofs := _northern_roots(world, A1226, A1226.ROOF_KEY)
	_require(target_1226_walls.size() == 1 and target_1226_roofs.size() == 1, "One ordinary1226 pair.")
	if target_1226_walls.size() == 1 and target_1226_roofs.size() == 1: _validate_projected_family(target_1226_walls[0], target_1226_roofs[0], A1226)
	main.queue_free()
	await process_frame

func _exists_with_remaps(path: String) -> bool:
	if FileAccess.file_exists(path) or ResourceLoader.exists(path):
		return true
	if path.ends_with(".gd"):
		return FileAccess.file_exists(path + ".remap") or FileAccess.file_exists(path.trim_suffix(".gd") + ".gdc")
	return false

func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}

func _require(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error("D2_1444_PACKAGE_FAIL: " + message)

func _live_node_contract_matches(wall: Node3D, roof: Node3D, wall_record: Dictionary) -> bool:
	if wall == null or roof == null \
	or wall.name != "D21444CroakerLiveWallReplacement" or roof.name != "D21444CroakerLiveRoofReplacement" \
	or wall.get_node_or_null("Mesh") != null or roof.get_node_or_null("Mesh") != null \
	or wall.get_node_or_null(ADAPTER.ROOF_MESH_NAME) != null or roof.get_node_or_null(ADAPTER.ROOF_MESH_NAME) == null:
		return false
	var wall_measure := _measure(wall)
	var roof_measure := _measure(roof)
	var wall_body := wall.get_node_or_null("Collision") as StaticBody3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	var wall_shape := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	if wall_measure != {"meshes": 10, "surfaces": 10, "triangles": 716, "bodies": 1, "shapes": 2} \
	or roof_measure != {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1} \
	or wall_body == null or roof_body == null or wall_shape == null or roof_shape == null \
	or not (wall_shape.shape is ConcavePolygonShape3D) or not (roof_shape.shape is ConcavePolygonShape3D):
		return false
	var wall_faces := (wall_shape.shape as ConcavePolygonShape3D).get_faces()
	var roof_faces := (roof_shape.shape as ConcavePolygonShape3D).get_faces()
	var meta := wall.get_meta("d2_1444_croaker_live_replacement", {}) as Dictionary
	var relief_triangles := 0
	for node: Node in wall.find_children("*", "MeshInstance3D", true, false):
		var instance := node as MeshInstance3D
		if instance.name not in ADAPTER.SOURCE_WALL_MESH_NAMES and instance.name not in ADAPTER.CLOSED_RECESS_MESH_NAMES:
			relief_triangles += int(instance.mesh.get_faces().size() / 3)
		if bool(instance.get_meta("prototype_only", true)) or not bool(instance.get_meta("runtime_attachment", false)):
			return false
	return wall_faces.size() == 192 and roof_faces.size() == 30 \
		and _face_signature(wall_faces) == ADAPTER._mesh_face_signature(wall, ADAPTER.SOURCE_WALL_MESH_NAMES) \
		and _closed_recess_contract(wall) \
		and relief_triangles == ADAPTER.EXPECTED_DECORATIVE_TRIANGLES \
		and wall_body.collision_layer == (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) \
		and roof_body.collision_layer == (PHYSICS_WORLD_SOLID | PHYSICS_SPRAY_SURFACE) \
		and wall_body.collision_mask == 0 and roof_body.collision_mask == 0 \
		and wall_body.is_in_group("spray_receiver_wall") and not roof_body.is_in_group("spray_receiver_wall") \
		and str(wall_body.get_meta("receiver_kind", "")) == "building_wall" \
		and str(wall_shape.shape.get_meta("receiver_kind", "")) == "building_wall" \
		and str(roof_body.get_meta("receiver_kind", "invalid")) == "none" \
		and bool(roof_body.get_meta("roof_landing_world_solid", false)) \
		and str(meta.get("adapter_id", "")) == ADAPTER.ADAPTER_ID \
		and str(meta.get("geometry_signature", "")) == ADAPTER.EXPECTED_GEOMETRY_SIGNATURE \
		and str(meta.get("live_ownership_signature", "")) == ADAPTER.EXPECTED_LIVE_OWNERSHIP_SIGNATURE \
		and str(meta.get("accepted_authority_schema", "")) == "ti.facade-runtime-registry/9" \
		and str(meta.get("accepted_recognition_metric", "")) == "9/213" \
		and int(meta.get("candidate_recognition_credit", -1)) == 0 \
		and not bool(meta.get("recognition_accepted", true)) and not bool(meta.get("believability_accepted", true)) \
		and meta.get("undercroft_run_indices", []) == [8, 9] \
		and meta.get("sparse_opening_run_indices", []) == [11, 16] \
		and meta.get("balcony_run_indices", []) == [17] \
		and meta.get("quiet_mapped_run_indices", []) == [12, 15] \
		and meta.get("protected_run_indices", []) == [0, 1, 2, 3, 4, 5, 6, 7, 10, 13, 14, 18, 19, 20, 21] \
		and not bool(meta.get("fallback_allowed", true)) and not bool(meta.get("partial_pair_allowed", true)) and not bool(meta.get("stack_allowed", true)) \
		and not wall.has_meta("config_path") and not wall.has_meta("deterministic_signature") \
		and wall.find_children("*", "NavigationRegion3D", true, false).is_empty() and wall.find_children("*", "Decal", true, false).is_empty() \
		and roof.find_children("*", "NavigationRegion3D", true, false).is_empty() \
		and _roof_ordered_front_and_collision_match(roof) and ADAPTER.material_semantics_match(wall, roof)


func _roof_ordered_front_and_collision_match(roof: Node3D) -> bool:
	var roof_mesh := roof.get_node_or_null(ADAPTER.ROOF_MESH_NAME) as MeshInstance3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	if roof_mesh == null or roof_mesh.mesh == null or roof_shape == null \
	or not (roof_shape.shape is ConcavePolygonShape3D) or not ADAPTER.roof_render_front_face_matches(roof_mesh):
		return false
	var visual_faces := roof_mesh.mesh.get_faces()
	var collision_faces := (roof_shape.shape as ConcavePolygonShape3D).get_faces()
	if visual_faces.size() != ADAPTER.EXPECTED_ROOF_VISUAL_TRIANGLES * 3 or collision_faces.size() != visual_faces.size():
		return false
	for offset in range(0, visual_faces.size(), 3):
		for corner in 3:
			if not visual_faces[offset + corner].is_equal_approx(collision_faces[offset + corner]):
				return false
		var visual_winding := (visual_faces[offset + 1] - visual_faces[offset]).cross(visual_faces[offset + 2] - visual_faces[offset]).normalized()
		var collision_winding := (collision_faces[offset + 1] - collision_faces[offset]).cross(collision_faces[offset + 2] - collision_faces[offset]).normalized()
		if visual_winding.y >= -0.4 or collision_winding.y >= -0.4:
			return false
	return true


func _closed_recess_contract(wall: Node3D) -> bool:
	var body := wall.get_node("Collision") as StaticBody3D
	var closure := wall.get_node_or_null("Collision/ClosedRecessShape") as CollisionShape3D
	if closure == null or body.get_child_count() != 2 or body.get_child(0).name != "Shape" or body.get_child(1) != closure:
		return false
	if not (closure.shape is ConcavePolygonShape3D) or str(closure.shape.get_meta("receiver_kind", "")) != "none":
		return false
	var faces := (closure.shape as ConcavePolygonShape3D).get_faces()
	if faces.size() != 120 or _face_signature(faces) != ADAPTER._mesh_face_signature(wall, ADAPTER.CLOSED_RECESS_MESH_NAMES):
		return false
	for name_value in ADAPTER.CLOSED_RECESS_MESH_NAMES:
		var mesh := wall.get_node(str(name_value)) as MeshInstance3D
		if mesh.layers != 1 or str(mesh.get_meta("collision_ownership", "")) != "noneligible_closed_recess_shape":
			return false
	return true


func _measure(root_node: Node) -> Dictionary:
	var result := {"meshes": 0, "surfaces": 0, "triangles": 0, "bodies": 0, "shapes": 0}
	for node: Node in _all_nodes(root_node):
		if node is MeshInstance3D:
			result.meshes += 1
			var mesh := (node as MeshInstance3D).mesh
			result.surfaces += mesh.get_surface_count()
			result.triangles += int(mesh.get_faces().size() / 3)
		elif node is StaticBody3D:
			result.bodies += 1
		elif node is CollisionShape3D:
			result.shapes += 1
	return result


func _face_signature(faces: PackedVector3Array) -> String:
	var triangles: Array[String] = []
	for offset in range(0, faces.size(), 3):
		var points: Array[String] = []
		for corner in 3:
			var point := faces[offset + corner]
			points.append("%.5f|%.5f|%.5f" % [point.x, point.y, point.z])
		points.sort()
		triangles.append("/".join(points))
	triangles.sort()
	return "\n".join(triangles).sha256_text()


func _record_roots(root_node: Node, object_key: String) -> Array[Node3D]:
	var result: Array[Node3D] = []
	for node: Node in root_node.find_children("*", "Node3D", true, false):
		if node.has_meta("feature_kind") and str(node.get_meta("derived_object_key", "")) == object_key:
			result.append(node as Node3D)
	return result


func _all_nodes(root_node: Node) -> Array[Node]:
	var result: Array[Node] = [root_node]
	for child: Node in root_node.get_children():
		result.append_array(_all_nodes(child))
	return result




func _mounted_component() -> void:
	# B225 shares this chunk and intentionally requires raw material bytes in
	# editor builds. Mount validation therefore dispatches only the exact 1444
	# records through the real builder after full supplied-chunk pair preflight.
	# Source and signed-release ordinary main validate complete chunk attachment.
	var chunk := _json("res://generated/world/chunks/x_-2__z_-1.json")
	var prepared := ADAPTER.prepare_chunk_records(chunk)
	_require(bool(prepared.get("ok", false)) and bool(prepared.get("contains_target", false)), "Mounted target pair preflight failed: %s" % prepared)
	if _failed:
		return
	var plan := ADAPTER.build_chunk_plan(prepared)
	_require(bool(plan.get("ok", false)) and bool(plan.get("contains_target", false)), "Mounted target pair plan failed: %s" % plan)
	if _failed:
		ADAPTER.free_unconsumed(plan)
		return
	var staging := Node3D.new()
	var builder := WorldChunkBuilder.new()
	for record: Dictionary in [prepared.wall, prepared.roof]:
		var result := builder._build_record(record, false, {}, {}, {}, plan)
		_require(bool(result.get("ok", false)), "Mounted ordinary builder target dispatch failed: %s" % result)
		if bool(result.get("ok", false)):
			staging.add_child(result.node)
	_require(ADAPTER.plan_was_fully_consumed(plan), "Mounted builder did not consume the sealed pair exactly once.")
	var walls := _record_roots(staging, ADAPTER.WALL_KEY)
	var roofs := _record_roots(staging, ADAPTER.ROOF_KEY)
	_require(walls.size() == 1 and roofs.size() == 1, "Mounted builder did not dispatch one atomic pair.")
	if walls.size() == 1 and roofs.size() == 1:
		_require(_live_node_contract_matches(walls[0], roofs[0], {}), "Mounted actual builder component geometry/collision/material contract failed.")
		if not _failed:
			print("D2_1444_MOUNTED_COMPONENT: wall=%s roof=%s collision_triangles=64+40+10, material/metadata/roof-winding exact; actual builder target-record dispatch after supplied-chunk pair preflight; full exported main verified separately by supported --mac-export-smoke" % [_measure(walls[0]), _measure(roofs[0])])
	ADAPTER.free_unconsumed(plan)
	staging.free()


func _mounted_new_pair(adapter: Script) -> void:
	# Full supplied chunk preflight; dispatch only this pair to preserve editor raw-source boundaries.
	var chunk := _json("res://generated/world/chunks/" + adapter.TARGET_CHUNK_ID + ".json")
	var prepared: Dictionary = adapter.prepare_chunk_records(chunk)
	_require(bool(prepared.get("ok", false)) and bool(prepared.get("contains_target", false)), "New mounted pair preflight " + adapter.SOURCE_KEY)
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var wm: StandardMaterial3D = builder._material_for("building_wall", "building_wall", false)
	var rm: StandardMaterial3D = builder._material_for("building_roof", "building_roof", false)
	var plan: Dictionary = adapter.build_chunk_plan(prepared, wm, rm)
	_require(bool(plan.get("ok", false)), "New mounted pair plan " + adapter.SOURCE_KEY)
	if _failed:
		adapter.free_unconsumed(plan)
		return
	var staging := Node3D.new()
	for key: String in [adapter.WALL_KEY, adapter.ROOF_KEY]:
		var record: Dictionary = prepared.source_records[key]
		var result: Dictionary
		if adapter == A1308: result = builder._build_record(record, false, {}, {}, {}, {}, plan)
		elif adapter == A1394: result = builder._build_record(record, false, {}, {}, {}, {}, {}, plan)
		else: result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, plan)
		_require(bool(result.get("ok", false)), "Real mounted new target dispatch " + key)
		if bool(result.get("ok", false)): staging.add_child(result.node)
	_require(adapter.plan_was_fully_consumed(plan), "New pair consumed exactly once " + adapter.SOURCE_KEY)
	var walls := _record_roots(staging, adapter.WALL_KEY)
	var roofs := _record_roots(staging, adapter.ROOF_KEY)
	_require(walls.size() == 1 and roofs.size() == 1, "Exactly one mounted new pair " + adapter.SOURCE_KEY)
	if walls.size() == 1 and roofs.size() == 1: _validate_new_pair(walls[0], roofs[0], adapter)
	adapter.free_unconsumed(plan)
	staging.free()

func _validate_new_pair(wall: Node3D, roof: Node3D, adapter: Script) -> void:
	var chunk := _json("res://generated/world/chunks/" + adapter.TARGET_CHUNK_ID + ".json")
	var prepared: Dictionary = adapter.prepare_chunk_records(chunk)
	_require(bool(prepared.get("ok", false)), "New comparison pair preflight " + adapter.SOURCE_KEY)
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var wm: StandardMaterial3D = builder._material_for("building_wall", "building_wall", false)
	var rm: StandardMaterial3D = builder._material_for("building_roof", "building_roof", false)
	var fresh: Dictionary
	if adapter == A1308: fresh = adapter.FACTORY.build_for_records(prepared.source_records[adapter.WALL_KEY], prepared.source_records[adapter.ROOF_KEY], wm, rm)
	else: fresh = adapter.FACTORY.build_for_records(prepared.source_records[adapter.WALL_KEY], prepared.source_records[adapter.ROOF_KEY], wm, rm, prepared.source_records)
	_require(bool(fresh.get("ok", false)), "Accepted new comparison factory " + adapter.SOURCE_KEY)
	if not bool(fresh.get("ok", false)): return
	_check_new_pair(wall, roof, fresh.node, adapter)
	var wall_counts: Dictionary = {"meshes": 14, "surfaces": 14, "triangles": 3469, "bodies": 1, "shapes": 4} if adapter == A1308 else {"meshes": 15, "surfaces": 15, "triangles": 3352, "bodies": 1, "shapes": 3}
	var roof_counts: Dictionary = {"meshes": 3,"surfaces":3,"triangles":1402,"bodies":1,"shapes":2} if adapter == A1308 else {"meshes":1,"surfaces":1,"triangles":16,"bodies":1,"shapes":1}
	if adapter == A1317:
		wall_counts = {"meshes":12,"surfaces":12,"triangles":1808,"bodies":1,"shapes":3}
		roof_counts = {"meshes":2,"surfaces":2,"triangles":130,"bodies":1,"shapes":2}
	_require(_measure(wall) == wall_counts and _measure(roof) == roof_counts, "Exact selected pair counts " + adapter.SOURCE_KEY)
	var unit := "1308" if adapter == A1308 else ("1394" if adapter == A1394 else "1317")
	var meta := wall.get_meta("d5_" + unit + "_gateview_live_replacement", {}) as Dictionary
	var geometry_field := "accepted_art002_geometry_sha256" if adapter == A1317 else "source_geometry_sha256"
	var expected_geometry: String = "48ba2658a74b4e51ab43fb07b3940a737ffa351350081063c45908e878a5bcf9" if adapter == A1317 else adapter.FACTORY.SOURCE_GEOMETRY_SHA256
	var metric_field := "captured_authority_metric" if adapter == A1317 else "accepted_recognition_metric"
	_require(meta == (roof.get_meta("d5_" + unit + "_gateview_live_replacement", {}) as Dictionary) and str(meta.get("adapter_id", "")) == adapter.ADAPTER_ID and str(meta.get(geometry_field, "")) == expected_geometry, "New pair metadata identity " + unit)
	_require(str(meta.get(metric_field, "")) == "13/213" and int(meta.get("candidate_recognition_credit", -1)) == 0 and not bool(meta.get("recognition_accepted", true)) and int(meta.get("factory_calls", -1)) == 1, "New pair historical authority/no credit " + unit)
	_require(not bool(meta.get("partial_pair_allowed", true)) and not bool(meta.get("fallback_allowed", true)) and not bool(meta.get("stack_allowed", true)), "New pair fail-closed metadata " + unit)
	print("D5_BATCH_PACKAGE_ATTACHMENT: unit=%s wall=%s roof=%s wall_counts=%s roof_counts=%s source_geometry=%s" % [unit, str(wall.get_path()) if wall.is_inside_tree() else "detached:" + str(wall.name), str(roof.get_path()) if roof.is_inside_tree() else "detached:" + str(roof.name), _measure(wall), _measure(roof), meta.get(geometry_field, "")])
	fresh.node.free()
func _check_new_pair(wall:Node3D,roof:Node3D,original:Node3D, adapter:Script) -> void:
	var body:=wall.get_node("Collision") as StaticBody3D;var rb:=roof.get_node("Collision") as StaticBody3D
	_require(body.collision_layer==5 and rb.collision_layer==5 and body.collision_mask==0 and rb.collision_mask==0 and body.is_in_group("spray_receiver_wall") and not rb.is_in_group("spray_receiver_wall"),"One eligible wall owner and blocking separate roof.")
	_require(body.get_child_count()==(4 if adapter == A1308 else 3) and rb.get_child_count()==(1 if adapter == A1394 else 2),"Exact per-unit shape partition.")
	var old:=original.get_node("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	var mapping: Array = [[body,0,0],[body,1,2],[body,2,3],[rb,0,1]]
	if adapter == A1308: mapping.append_array([[body,3,4],[rb,1,5]])
	elif adapter == A1317: mapping.append([rb,1,4])
	for spec:Array in mapping:
		_require(spec[0].get_child(spec[1]).shape.get_faces()==old.get_child(spec[2]).shape.get_faces(),"Exact accepted structural face data retained through split "+str(spec[2]))
	for i in body.get_child_count():_require(str(body.get_child(i).shape.get_meta("receiver_kind"))==("building_wall" if i==0 else "none"),"Wall shape eligibility "+str(i))
	for i in rb.get_child_count(): _require(str(rb.get_child(i).shape.get_meta("receiver_kind"))=="none","Roof nonreceiver.")
	for root:Node3D in [wall,roof]:
		for child:Node in root.get_children():
			if child is MeshInstance3D:
				_require(child.mesh.surface_get_arrays(0)==original.get_node(NodePath(child.name)).mesh.surface_get_arrays(0),"Exact split visual arrays "+str(child.name))
				_require(child.get_active_material(0)==original.get_node(NodePath(child.name)).get_active_material(0) or _material_equal(child.get_active_material(0),original.get_node(NodePath(child.name)).get_active_material(0)),"Split material semantics "+str(child.name))
				_require(child.layers==(2 if str(child.name) in adapter.WALL_MESHES else 1),"Decal/render layer partition "+str(child.name))

func _material_equal(a:Material,b:Material) -> bool:
	return _material_state(a)==_material_state(b)
func _material_state(material:Material) -> Dictionary:
	var state:Dictionary={"class":material.get_class()}
	for property:Dictionary in material.get_property_list():
		if (int(property.usage)&PROPERTY_USAGE_STORAGE)==0 or str(property.name) in ["script","resource_path"]:continue
		var value:Variant=material.get(str(property.name))
		if value is Resource:
			state[str(property.name)]={"class":value.get_class(),"path":value.resource_path,"name":value.resource_name}
			if value is Shader:state[str(property.name)]["code_sha256"]=value.code.sha256_text()
		else:state[str(property.name)]=var_to_bytes(value).hex_encode()
	return state

func _mounted_station48() -> void:
	var chunk := _json("res://generated/world/chunks/" + AFS.TARGET_CHUNK_ID + ".json")
	var prepared: Dictionary = AFS.prepare_chunk_records(chunk)
	_require(bool(prepared.get("ok", false)) and bool(prepared.get("contains_target", false)), "Station48 full supplied-chunk preflight.")
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var plan: Dictionary = AFS.build_chunk_plan(prepared, Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
	_require(bool(plan.get("ok", false)), "Station48 mounted pair construction.")
	if _failed:
		AFS.free_unconsumed(plan)
		return
	var staging := Node3D.new()
	for key: String in [AFS.WALL_KEY, AFS.ROOF_KEY]:
		var record: Dictionary = prepared.source_records[key]
		var result: Dictionary = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, plan)
		_require(bool(result.get("ok", false)), "Station48 real tenth-argument builder dispatch: " + key)
		if bool(result.get("ok", false)): staging.add_child(result.node)
	_require(AFS.plan_was_fully_consumed(plan), "Station48 pair consumed exactly once.")
	var walls := _record_roots(staging, AFS.WALL_KEY)
	var roofs := _record_roots(staging, AFS.ROOF_KEY)
	_require(walls.size() == 1 and roofs.size() == 1, "One mounted Station48 wall/roof pair.")
	if walls.size() == 1 and roofs.size() == 1: _validate_station48(walls[0], roofs[0])
	AFS.free_unconsumed(plan)
	staging.free()

func _validate_station48(wall: Node3D, roof: Node3D) -> void:
	var chunk := _json("res://generated/world/chunks/" + AFS.TARGET_CHUNK_ID + ".json")
	var prepared: Dictionary = AFS.prepare_chunk_records(chunk)
	_require(bool(prepared.get("ok", false)), "Station48 comparison records.")
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var fresh: Dictionary = AFS.FACTORY.build_for_records(prepared.source_records[AFS.WALL_KEY], prepared.source_records[AFS.ROOF_KEY], Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
	_require(bool(fresh.get("ok", false)), "Station48 fresh same-runtime accepted factory.")
	if not bool(fresh.get("ok", false)): return
	var original := fresh.node as Node3D
	var body := wall.get_node("Collision") as StaticBody3D
	var rb := roof.get_node("Collision") as StaticBody3D
	var old := original.get_node("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	_require(wall.name == "FireStation48LiveWallReplacement" and roof.name == "FireStation48LiveRoofReplacement", "Station48 exact root names.")
	_require(_measure(wall) == {"meshes":6,"surfaces":6,"triangles":1080,"bodies":1,"shapes":1} and _measure(roof) == {"meshes":1,"surfaces":1,"triangles":10,"bodies":1,"shapes":1}, "Station48 exact wall6/1080/52 and roof1/10/10 partitions.")
	_require(body.collision_layer == 5 and rb.collision_layer == 5 and body.collision_mask == 0 and rb.collision_mask == 0 and body.is_in_group("spray_receiver_wall") and not rb.is_in_group("spray_receiver_wall"), "Station48 wall eligibility and blocking roof layers.")
	_require(body.get_child_count() == 1 and rb.get_child_count() == 1 and old.get_child_count() == 2, "Station48 source-only shape partition.")
	for spec: Array in [[body,0,AFS.WALL_KEY,"building_wall",52],[rb,1,AFS.ROOF_KEY,"none",10]]:
		var shape := spec[0].get_child(0) as CollisionShape3D
		_require(shape.shape.get_faces() == old.get_child(spec[1]).shape.get_faces() and shape.shape.get_faces().size() == int(spec[4])*3, "Station48 original ordered collision " + str(spec[2]))
		for object: Object in [spec[0],shape,shape.shape]:
			_require(str(object.get_meta("derived_object_key", "")) == str(spec[2]) and object.get_meta("source_keys", []) == [AFS.SOURCE_KEY] and str(object.get_meta("receiver_kind", "")) == str(spec[3]) and bool(object.get_meta("opaque", false)), "Station48 exact source/shape receiver ownership " + str(spec[2]))
	var seen: Dictionary = {}
	for target: Node3D in [wall,roof]:
		for child: Node in target.get_children():
			if child is MeshInstance3D:
				var baseline := original.get_node(NodePath(child.name)) as MeshInstance3D
				_require(child.mesh.surface_get_arrays(0) == baseline.mesh.surface_get_arrays(0) and child.transform == baseline.transform and child.cast_shadow == baseline.cast_shadow, "Station48 full native channels/transform/shadow: " + str(child.name))
				_require(_material_equal(child.get_active_material(0),baseline.get_active_material(0)), "Station48 complete material/shader parameters: " + str(child.name))
				_require(child.layers == (2 if str(child.name) in AFS.WALL_MESHES else 1), "Station48 protected/public source walls retain decal layer2; additions/roof layer1.")
				seen[str(child.name)] = true
	_require(seen.size() == 7, "All seven Station48 mesh names compared.")
	var meta := wall.get_meta("fire_station48_live_replacement", {}) as Dictionary
	_require(meta == (roof.get_meta("fire_station48_live_replacement", {}) as Dictionary) and str(meta.get("adapter_id", "")) == AFS.ADAPTER_ID and str(meta.get("accepted_study002_geometry_sha256", "")) == "e198f49df39671d489bb96cd553ec257df12156a0921b489f434d2c2b37d7597", "Station48 shared exact geometry/adapter metadata.")
	_require(str(meta.get("captured_authority_metric", "")) == "14/213" and int(meta.get("candidate_recognition_credit", -1)) == 0 and not bool(meta.get("recognition_accepted", true)) and int(meta.get("factory_calls", -1)) == 1, "Station48 retains historical14 uncredited product metadata.")
	_require(not bool(meta.get("partial_pair_allowed", true)) and not bool(meta.get("fallback_allowed", true)) and not bool(meta.get("stack_allowed", true)) and bool(meta.get("all_additions_render_only", false)) and bool(meta.get("source_collision_only", false)), "Station48 atomic source-only collision contract.")
	_require(meta.get("mapped_public_run_indices", []) == AFS.FACTORY.TARGET_RUNS and meta.get("protected_run_indices", []) == AFS.FACTORY.PROTECTED_RUNS, "Station48 exact public/protected ownership.")
	var registry := _json(REGISTRY)
	var unit_matches := 0
	for unit: Dictionary in registry.get("units", []):
		if str(unit.get("unit_id", "")) == "physical-building:w764313741":
			unit_matches += 1
			_require((unit.get("acceptance_records", []) as Array) == JSON.parse_string(JSON.stringify([{"evidence_manifest_sha256": "f68b77fa5c6e8983288ad9f9ca36a4fd827e716cc1c99877270eeceb547786b6", "motion_telemetry_manifest_sha256": "4e3a0ea032384bc1381468db84ae15c4ebc1eb75212a9fec20156d165414b028", "visual_motion_manifest_sha256": "708692fe592b56c9b18cbf5d9bbc086dadb1c053153d37afbd5c37c6a91c0a3e", "package_verification_receipt_sha256": "502c87a102c90ef446a1e3415b1bb6eca7050d46689c550c18609c3c9dc43b0b", "evidence_tree_sha256": "6e8e1a6d8ff3ee12e961d7adaa78cdc72e8aa57dbb607251d5a1361c171eb895", "mechanical_review_receipt_sha256": "fb4802671d8ec92d2cdff091a221fc6fe8f3d1dae6780446aa5604227f7cfed4", "review_receipt_sha256": "cb06367c7de02d2379c855dfe33915d8bd54b85a33666f0582e949752f9310cf", "capture_time_recognition_metric": "14/213", "numerator_effect": 1, "review_id": "fire-station48-quality-candidate-2026-09-11-001", "review_kind": "independent_reference_recognition", "status": "accept"}])) and (unit.get("active_runtime_adapter_ids", []) as Array) == ["active-adapter:fire-station48-live:building:w764313741:wall"], "Station48 preserved accepted record in current23 and sole active adapter; historical product config stays captured14/credit0.")
	_require(unit_matches == 1, "Exactly one immutable Station48 physical unit.")
	print("FIRE_STATION48_PACKAGE_ATTACHMENT: wall=%s roof=%s seven_native_arrays/materials_exact=true source_collision=52+10 current_authority=32/213 historical_config_authority=14/213 historical_config_credit=0" % [_measure(wall),_measure(roof)])
	original.free()


func _mounted_maceo() -> void:
	var chunk := _json("res://generated/world/chunks/" + AM.TARGET_CHUNK_ID + ".json")
	var prepared: Dictionary = AM.prepare_chunk_records(chunk)
	_require(bool(prepared.get("ok", false)) and bool(prepared.get("contains_target", false)), "Maceo full supplied-chunk preflight.")
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var plan: Dictionary = AM.build_chunk_plan(prepared, Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
	_require(bool(plan.get("ok", false)), "Maceo mounted pair construction.")
	if _failed:
		AM.free_unconsumed(plan)
		return
	var staging := Node3D.new()
	for key: String in [AM.WALL_KEY, AM.ROOF_KEY]:
		var record: Dictionary = prepared.source_records[key]
		var result: Dictionary = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, plan)
		_require(bool(result.get("ok", false)), "Maceo real eleventh-argument builder dispatch: " + key)
		if bool(result.get("ok", false)): staging.add_child(result.node)
	_require(AM.plan_was_fully_consumed(plan), "Maceo pair consumed exactly once.")
	var walls := _record_roots(staging, AM.WALL_KEY)
	var roofs := _record_roots(staging, AM.ROOF_KEY)
	_require(walls.size() == 1 and roofs.size() == 1, "One mounted Maceo wall/roof pair.")
	if walls.size() == 1 and roofs.size() == 1: _validate_maceo(walls[0], roofs[0])
	AM.free_unconsumed(plan)
	staging.free()

func _validate_maceo(wall: Node3D, roof: Node3D) -> void:
	var chunk := _json("res://generated/world/chunks/" + AM.TARGET_CHUNK_ID + ".json")
	var prepared: Dictionary = AM.prepare_chunk_records(chunk)
	_require(bool(prepared.get("ok", false)), "Maceo comparison records.")
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var fresh: Dictionary = AM.FACTORY.build_for_records(prepared.source_records[AM.WALL_KEY], prepared.source_records[AM.ROOF_KEY], Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
	_require(bool(fresh.get("ok", false)), "Maceo fresh same-runtime accepted factory.")
	if not bool(fresh.get("ok", false)): return
	var original := fresh.node as Node3D
	var body := wall.get_node("Collision") as StaticBody3D
	var rb := roof.get_node("Collision") as StaticBody3D
	var old := original.get_node("ExactFootprintStructuralCollision_NoSprayOwnership") as StaticBody3D
	_require(wall.name == "MaceoMayLiveWallReplacement" and roof.name == "MaceoMayLiveRoofReplacement", "Maceo exact root names.")
	_require(_measure(wall) == {"meshes":10,"surfaces":10,"triangles":16420,"bodies":1,"shapes":2} and _measure(roof) == {"meshes":1,"surfaces":1,"triangles":16,"bodies":1,"shapes":1}, "Maceo exact wall and roof partitions.")
	_require(body.collision_layer == 5 and rb.collision_layer == 5 and body.collision_mask == 0 and rb.collision_mask == 0 and body.is_in_group("spray_receiver_wall") and not rb.is_in_group("spray_receiver_wall"), "Maceo wall eligibility and blocking roof layers.")
	_require(str(body.get_meta("receiver_kind", "")) == "building_wall" and str(rb.get_meta("receiver_kind", "")) == "none", "Maceo body-level wall and roof ownership.")
	_require(body.get_child_count() == 2 and rb.get_child_count() == 1 and old.get_child_count() == 3, "Maceo source/column/roof shape partition.")
	for spec: Array in [[body,0,0,AM.WALL_KEY,"building_wall",80],[body,1,2,AM.WALL_KEY,"none",320],[rb,0,1,AM.ROOF_KEY,"none",16]]:
		var shape := spec[0].get_child(spec[1]) as CollisionShape3D
		_require(shape.shape.get_faces() == old.get_child(spec[2]).shape.get_faces() and shape.shape.get_faces().size() == int(spec[5])*3, "Maceo original ordered collision " + str(spec[3]) + " shape " + str(spec[1]))
		for object: Object in [shape,shape.shape]:
			_require(str(object.get_meta("derived_object_key", "")) == str(spec[3]) and object.get_meta("source_keys", []) == [AM.SOURCE_KEY] and str(object.get_meta("receiver_kind", "")) == str(spec[4]) and bool(object.get_meta("opaque", false)), "Maceo exact shape receiver ownership.")
	_require(body.get_child(1).name == "EntranceColumnRelief", "Maceo visible columns remain a separately named nonreceiver shape.")
	var seen: Dictionary = {}
	for target: Node3D in [wall,roof]:
		for child: Node in target.get_children():
			if child is MeshInstance3D:
				var baseline := original.get_node(NodePath(child.name)) as MeshInstance3D
				_require(child.mesh.surface_get_arrays(0) == baseline.mesh.surface_get_arrays(0) and child.transform == baseline.transform and child.cast_shadow == baseline.cast_shadow, "Maceo full thirteen native channels/transform/shadow: " + str(child.name))
				_require(_material_equal(child.get_active_material(0),baseline.get_active_material(0)), "Maceo complete material/shader parameters: " + str(child.name))
				_require(child.layers == (2 if str(child.name) in AM.WALL_MESHES else 1), "Maceo source walls retain decal layer2; additions/roof layer1.")
				seen[str(child.name)] = true
	_require(seen.size() == 11, "All eleven Maceo mesh names compared.")
	var meta := wall.get_meta("maceo_may_live_replacement", {}) as Dictionary
	_require(meta == (roof.get_meta("maceo_may_live_replacement", {}) as Dictionary) and str(meta.get("adapter_id", "")) == AM.ADAPTER_ID and str(meta.get("curtain_repaired_geometry_sha256", "")) == "4caf46d6c3ebb1ef497fbe8012e5f1fd938a055e11a4132c04ed8e6827da12b3", "Maceo shared exact geometry/adapter metadata.")
	_require(str(meta.get("captured_authority_metric", "")) == "14/213" and int(meta.get("candidate_recognition_credit", -1)) == 0 and not bool(meta.get("recognition_accepted", true)) and int(meta.get("factory_calls", -1)) == 1, "Maceo retains historical14 uncredited metadata.")
	_require(not bool(meta.get("partial_pair_allowed", true)) and not bool(meta.get("fallback_allowed", true)) and not bool(meta.get("stack_allowed", true)) and not bool(meta.get("all_additions_render_only", true)) and not bool(meta.get("source_collision_only", true)), "Maceo atomic source plus separate visible-column contract.")
	_require(str(meta.get("added_collision_scope", "")) == "Five unchanged visible round columns, separate nonreceiver shape", "Maceo precise added collision scope.")
	_require(meta.get("mapped_public_run_indices", []) == AM.FACTORY.TARGET_RUNS and meta.get("protected_run_indices", []) == AM.FACTORY.PROTECTED_RUNS, "Maceo exact public/protected ownership.")
	var registry := _json(REGISTRY)
	var unit_matches := 0
	for unit: Dictionary in registry.get("units", []):
		if str(unit.get("unit_id", "")) == "physical-building:r19685981":
			unit_matches += 1
			_require((unit.get("acceptance_records", []) as Array) == JSON.parse_string("[{\"evidence_manifest_sha256\":\"82543ad09bc51281499280965d9bc949ecc99781d80520801742bd3643404862\",\"motion_telemetry_manifest_sha256\":\"83a8637cd539efa3899b8d97147a82a02d976aa8baed4209824e2724a2ac7e2b\",\"visual_motion_manifest_sha256\":\"3c7c3e933062d4cf3994f47cb48a62c41b7c1cf42fa41693ff82474cec1db86d\",\"package_verification_receipt_sha256\":\"e903e64348aa003ca957b1e1efebc57a516395134f40d56e1ba1c5ebc3ad877f\",\"evidence_tree_sha256\":\"916457b92cee4b002cab5c47b6ecd29a8c8d398a9ad685c05e7bc8f5d9874e0a\",\"mechanical_review_receipt_sha256\":\"749cd826a0ea791b696ab98464e5c19548f14d45734d88111a79376a74dd5c8c\",\"review_receipt_sha256\":\"e08d71c45bfc67e05ab2fd2a8d4e8362ef7692f96d5817d60856a251b473b14e\",\"capture_time_recognition_metric\":\"14/213\",\"numerator_effect\":1,\"review_id\":\"maceo-may-quality-candidate-2026-09-11-001\",\"review_kind\":\"independent_reference_recognition\",\"status\":\"accept\"}]") and (unit.get("active_runtime_adapter_ids", []) as Array) == ["active-adapter:maceo-may-live:building:r19685981:wall"], "Maceo exact accepted current23 record and sole active adapter; historical14 product and candidate15 package scopes retained.")
	_require(unit_matches == 1, "Exactly one immutable Maceo physical unit.")
	print("MACEO_MAY_PACKAGE_ATTACHMENT: wall=%s roof=%s eleven_native_arrays/materials_exact=true source_collision=80+16 separate_column_collision=320 current_authority=32/213 historical_config_authority=14/213 historical_config_credit=0" % [_measure(wall),_measure(roof)])
	original.free()


func _mounted_northern(adapter: Script, roof_triangles: int) -> void:
	var prepared: Dictionary = adapter.prepare_chunk_records(_json(adapter.FACTORY.CHUNK_PATH))
	_require(bool(prepared.get("ok", false)) and bool(prepared.get("contains_target", false)), "Northern exact supplied pair: " + adapter.SOURCE_KEY)
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var counts := {"raw": [], "detail_tangents": 0}
	var raw := func(record: Dictionary, context: bool) -> Dictionary:
		counts.raw.append({"key": str(record.object_key), "is_context": context})
		return builder._build_unpaired_record(record, context)
	var tangents := func(vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> PackedFloat32Array:
		counts.detail_tangents += 1
		return builder._tangents_for(vertices, normals, uvs, indices)
	var plan: Dictionary = adapter.build_chunk_plan(prepared, raw, tangents)
	_require(bool(plan.get("ok", false)), "Northern package callback construction: " + adapter.SOURCE_KEY)
	if not bool(plan.get("ok", false)):
		adapter.free_unconsumed(plan)
		return
	_require(counts.raw == [{"key": adapter.WALL_KEY, "is_context": false}, {"key": adapter.ROOF_KEY, "is_context": false}] and counts.detail_tangents == 9, "Northern actual raw2/detail9 callbacks: " + adapter.SOURCE_KEY)
	var staging := Node3D.new()
	var pair: Dictionary = {}
	for key: String in [adapter.WALL_KEY, adapter.ROOF_KEY]:
		var record: Dictionary = prepared.source_records[key]
		var result: Dictionary
		if adapter == A1201:
			result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
		else:
			result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
		_require(bool(result.get("ok", false)), "Northern real twelfth/thirteenth argument dispatch: " + key)
		if bool(result.get("ok", false)):
			pair[key] = result.node
			staging.add_child(result.node)
			var measured := _measure(result.node)
			_require([result.mesh_instances, result.surfaces, result.triangles, result.static_bodies, result.shapes] == [measured.meshes, measured.surfaces, measured.triangles, measured.bodies, measured.shapes], "Northern direct result counters equal native descendants: " + key)
			var metadata: Dictionary = result.metadata
			_require(metadata.adapter_id == adapter.ADAPTER_ID and metadata.source_key == adapter.SOURCE_KEY and metadata.factory_calls == 1 and metadata.mapped_public_run_indices == adapter.MAPPED_RUNS and metadata.protected_run_indices == adapter.PROTECTED_RUNS, "Northern result factory and ownership metadata: " + key)
			_require(not metadata.partial_pair_allowed and not metadata.fallback_allowed and not metadata.stack_allowed and not metadata.recognition_accepted and metadata.package_attachment_pending and metadata.original_source_channels_and_roof_preserved and metadata.source_wall_spray_eligibility_preserved, "Northern unchanged fail-closed uncredited result contract: " + key)
	_require(adapter.plan_was_fully_consumed(plan) and plan.records.is_empty() and pair.size() == 2, "Northern pair consumed exactly once: " + adapter.SOURCE_KEY)
	_require(not bool(adapter.consume_record(prepared.source_records[adapter.WALL_KEY], plan).ok), "Northern duplicate consumption rejects.")
	if pair.size() == 2:
		_validate_northern(pair[adapter.WALL_KEY], pair[adapter.ROOF_KEY], adapter, roof_triangles)
	adapter.free_unconsumed(plan)
	for node: Node in pair.values(): _require(is_instance_valid(node), "Consumed northern roots survive pending cleanup.")
	staging.free()
	for node: Variant in pair.values(): _require(not is_instance_valid(node), "Northern consumed staging roots release.")
	for first: String in ["", adapter.WALL_KEY, adapter.ROOF_KEY]:
		var cleanup: Dictionary = adapter.build_chunk_plan(prepared, Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
		_require(bool(cleanup.get("ok", false)), "Northern complete/half cleanup construction.")
		if not bool(cleanup.get("ok", false)): continue
		var pending: Array = []
		for result: Dictionary in cleanup.records.values(): pending.append(result.node)
		var consumed: Node = null
		if not first.is_empty(): consumed = adapter.consume_record(prepared.source_records[first], cleanup).node
		var survives: Array[bool] = []
		for node: Node in pending: survives.append(node == consumed)
		adapter.free_unconsumed(cleanup)
		_require(cleanup.records.is_empty() and cleanup.pending_keys.is_empty() and adapter.plan_was_fully_consumed(cleanup), "Northern cleanup clears complete pending maps.")
		for index in pending.size(): _require(is_instance_valid(pending[index]) == survives[index], "Northern cleanup frees only unconsumed roots.")
		if consumed != null: consumed.free()


func _validate_northern(wall: Node3D, roof: Node3D, adapter: Script, roof_triangles: int) -> void:
	var probe := GameMain.new()
	_require(probe._mac_export_northern_pair_valid(wall, roof, adapter, roof_triangles), "Northern package split/source receiver/detail/ordered-face predicate: " + adapter.SOURCE_KEY)
	probe.free()
	var prepared: Dictionary = adapter.prepare_chunk_records(_json(adapter.FACTORY.CHUNK_PATH))
	var builder := WorldChunkBuilder.new()
	var fresh: Dictionary = adapter.FACTORY.build_for_records(prepared.source_records[adapter.WALL_KEY], prepared.source_records[adapter.ROOF_KEY], Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
	_require(bool(fresh.get("ok", false)), "Northern same-runtime pinned factory comparison: " + adapter.SOURCE_KEY)
	if not bool(fresh.get("ok", false)): return
	var original: Node3D = fresh.node
	var seen: Array[String] = []
	var channel_count := 0
	for outer: Node3D in [wall, roof]:
		for child: Node in outer.get_children():
			var before := original.get_node_or_null(NodePath(child.name))
			_require(before != null, "Northern exact original child: " + str(child.name))
			if before == null: continue
			if child is MeshInstance3D:
				seen.append(str(child.name))
				_require(child.mesh != null and before is MeshInstance3D and before.mesh != null, "Northern mesh pair exists.")
				if child.mesh == null or not before is MeshInstance3D or before.mesh == null: continue
				_require(child.mesh.get_class() == before.mesh.get_class() and child.mesh.get_surface_count() == 1 and before.mesh.get_surface_count() == 1 and child.transform == before.transform and child.layers == before.layers and child.cast_shadow == before.cast_shadow, "Northern exact mesh class/partition/transform/layers/shadow: " + str(child.name))
				var a: Array = child.mesh.surface_get_arrays(0)
				var b: Array = before.mesh.surface_get_arrays(0)
				_require(a.size() == 13 and b.size() == 13 and Mesh.ARRAY_MAX == 13, "Northern all thirteen native channels.")
				if a.size() == 13 and b.size() == 13:
					for channel in Mesh.ARRAY_MAX:
						_require(var_to_bytes(a[channel]) == var_to_bytes(b[channel]), "Northern native channel " + str(channel) + ": " + str(child.name))
						channel_count += 1
				var an: Variant = child.mesh.surface_get_name(0) if child.mesh is ArrayMesh else null
				var bn: Variant = before.mesh.surface_get_name(0) if before.mesh is ArrayMesh else null
				_require(an == bn and _material_equal(child.get_active_material(0), before.get_active_material(0)), "Northern guarded surface name and complete stored material/shader state: " + str(child.name))
			else:
				_require(_northern_snapshot(child) == _northern_snapshot(before), "Northern complete nested original/detail transforms/ownership/ordered shape buffers: " + str(child.name))
	_require(seen.size() == 11 and channel_count == 143, "Northern all eleven meshes and 143 channel slots compared.")
	var source_units := 0
	for unit: Dictionary in _json(REGISTRY).get("units", []):
		if str(unit.get("unit_id", "")) == "physical-building:" + adapter.SOURCE_KEY:
			source_units += 1
			var accepted: Dictionary = JSON.parse_string("{\"physical-building:w96215669\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"16/213\",\"evidence_manifest_sha256\":\"5eb7648cb03fa1ae73c9733c31456539d39c40a462219be43d4a92ecf7d0ce62\",\"evidence_tree_sha256\":\"a2e2b8aade40eebd01d900728e65c5cabd2cb1f43465399db2ed90329d49a741\",\"mechanical_review_receipt_sha256\":\"6e5961faa00944e793c213e444a96732494a6fe15e1799f06636bdd1dd7ad276\",\"motion_telemetry_manifest_sha256\":\"fb3f03daae24bb385cbf6e86ee665a2752017ee9c5c32f54c6e21d00dbc7faf3\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"5b6b2455b8068568e2b877b9f155982af76e4cc81f7be3341e9ec663c7c260de\",\"review_id\":\"northern-1238-quality-candidate-2026-09-13-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"805f12798185ad8504cfac0742a27bdcb83c9da79b9aa9a192ba84081117fbab\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"35edd4f41d0cf9009aa59f66b0345992a93bb08ecd1eda8b61086b6eb5dc09db\"}],\"active_runtime_adapter_ids\":[\"active-adapter:northpoint-1238-live:building:w96215669:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215672\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"15/213\",\"evidence_manifest_sha256\":\"fc250debbc032d160e3de5e3e0148f13934a7e3bb17cc882a19f4d5b336fab95\",\"evidence_tree_sha256\":\"df08d70aa4307e2b7689e6c8e3ff0ad31005806b14c2420251456ddb4c60db92\",\"mechanical_review_receipt_sha256\":\"f449c7863040df9873f5bcd268e0eac506a9c26d6e0613881e1b294e9355bb1f\",\"motion_telemetry_manifest_sha256\":\"5a5de738ac8e8ed4490d4c83d63a739d5cdb9598ce66021984579dac1bf6e0c4\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"21be51860e8e35dcdf76df4753d22155cbca013f134250b365764e873b8eac86\",\"review_id\":\"northern-1201-quality-candidate-2026-09-13-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"11f87bb5defc8432d5ba53e8e2eb586f631cd81db920f5fa85dc61cc34261589\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"c0fcacf741e513402d0b04aa35c7d5927b4205ebb80c85890a62bd2b5456c77d\"}],\"active_runtime_adapter_ids\":[\"active-adapter:northern-canopy-free-live:building:w96215672:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}}}")
			var expected: Dictionary = accepted["physical-building:" + adapter.SOURCE_KEY]
			_require((unit.get("acceptance_records", []) as Array) == expected.acceptance_records and (unit.get("active_runtime_adapter_ids", []) as Array) == expected.active_runtime_adapter_ids and expected.active_runtime_adapter_ids == [adapter.ADAPTER_ID] and (unit.get("claim_status", {}) as Dictionary) == expected.claim_status, "Northern exact accepted current31 record, sole adapter and claim state; capture metadata remains historical.")
	_require(source_units == 1, "One immutable northern unit identity.")
	if not _failed:
		print("NORTHERN_PACKAGE_ATTACHMENT: source=%s wall=%s roof=%s native_channels=143 materials=11 source_plus_detail_shapes=9 current_authority=32/213 credit=0" % [adapter.SOURCE_KEY, _measure(wall), _measure(roof)])
	original.free()


func _northern_roots(world: Node3D, adapter: Script, key: String) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for node: Node in world.find_children("*", "Node3D", true, false):
		if not node is MeshInstance3D and not node is CollisionObject3D and str(node.get_meta("derived_object_key", "")) == key and str(node.get_meta("adapter_id", "")) == adapter.ADAPTER_ID and bool(node.get_meta("runtime_attachment", false)):
			found.append(node as Node3D)
	return found


func _northern_snapshot(node: Node) -> Dictionary:
	var out: Dictionary = {"class": node.get_class(), "name": str(node.name), "children": [], "metadata": {}}
	if node is Node3D: out["transform"] = var_to_bytes(node.transform).hex_encode()
	for key: StringName in node.get_meta_list(): out.metadata[str(key)] = var_to_bytes(node.get_meta(key)).hex_encode()
	if node is CollisionObject3D:
		out["layer"] = node.collision_layer
		out["mask"] = node.collision_mask
		out["wall_group"] = node.is_in_group("spray_receiver_wall")
	if node is CollisionShape3D:
		out["disabled"] = node.disabled
		out["shape_class"] = node.shape.get_class()
		out["shape_metadata"] = {}
		for key: StringName in node.shape.get_meta_list(): out.shape_metadata[str(key)] = var_to_bytes(node.shape.get_meta(key)).hex_encode()
		if node.shape is ConcavePolygonShape3D: out["faces"] = var_to_bytes(node.shape.get_faces()).hex_encode()
	for child: Node in node.get_children(): out.children.append(_northern_snapshot(child))
	return out


func _mounted_mariner(adapter: Script) -> void:
	var prepared: Dictionary = adapter.prepare_chunk_records(_json(adapter.FACTORY.CHUNK_PATH))
	_require(bool(prepared.get("ok", false)) and bool(prepared.get("contains_target", false)), "Mariner exact supplied pair: " + adapter.SOURCE_KEY)
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var counts := {"raw": [], "detail_tangents": 0}
	var raw := func(record: Dictionary, context: bool) -> Dictionary:
		counts.raw.append({"key": str(record.object_key), "is_context": context})
		return builder._build_unpaired_record(record, context)
	var tangents := func(vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> PackedFloat32Array:
		counts.detail_tangents += 1
		return builder._tangents_for(vertices, normals, uvs, indices)
	var plan: Dictionary = adapter.build_chunk_plan(prepared, raw, tangents)
	_require(bool(plan.get("ok", false)), "Mariner package callback construction: " + adapter.SOURCE_KEY)
	if not bool(plan.get("ok", false)):
		adapter.free_unconsumed(plan)
		return
	_require(counts.raw == [{"key": adapter.WALL_KEY, "is_context": false}, {"key": adapter.ROOF_KEY, "is_context": false}] and counts.detail_tangents == 12, "Mariner actual raw2/detail12 callbacks: " + adapter.SOURCE_KEY)
	var staging := Node3D.new()
	var pair: Dictionary = {}
	for key: String in [adapter.WALL_KEY, adapter.ROOF_KEY]:
		var record: Dictionary = prepared.source_records[key]
		var result: Dictionary
		if adapter == A1206:
			result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
		else:
			result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
		_require(bool(result.get("ok", false)), "Mariner real fourteenth/fifteenth argument dispatch: " + key)
		if bool(result.get("ok", false)):
			pair[key] = result.node
			staging.add_child(result.node)
			var measured := _measure(result.node)
			_require([result.mesh_instances, result.surfaces, result.triangles, result.static_bodies, result.shapes] == [measured.meshes, measured.surfaces, measured.triangles, measured.bodies, measured.shapes], "Mariner direct result counters equal native descendants: " + key)
			var metadata: Dictionary = result.metadata
			_require(metadata.adapter_id == adapter.ADAPTER_ID and metadata.source_key == adapter.SOURCE_KEY and metadata.factory_calls == 1 and metadata.mapped_public_run_indices == adapter.MAPPED_RUNS and metadata.protected_run_indices == adapter.PROTECTED_RUNS, "Mariner result factory and ownership metadata: " + key)
			_require(not metadata.partial_pair_allowed and not metadata.fallback_allowed and not metadata.stack_allowed and not metadata.recognition_accepted and metadata.package_attachment_pending and metadata.original_source_channels_and_roof_preserved and metadata.source_wall_spray_eligibility_preserved, "Mariner unchanged fail-closed uncredited result contract: " + key)
	_require(adapter.plan_was_fully_consumed(plan) and plan.records.is_empty() and pair.size() == 2, "Mariner pair consumed exactly once: " + adapter.SOURCE_KEY)
	_require(not bool(adapter.consume_record(prepared.source_records[adapter.WALL_KEY], plan).ok), "Mariner duplicate consumption rejects.")
	if pair.size() == 2:
		_validate_mariner(pair[adapter.WALL_KEY], pair[adapter.ROOF_KEY], adapter)
	adapter.free_unconsumed(plan)
	for node: Node in pair.values(): _require(is_instance_valid(node), "Consumed mariner roots survive pending cleanup.")
	staging.free()
	for node: Variant in pair.values(): _require(not is_instance_valid(node), "Mariner consumed staging roots release.")
	for first: String in ["", adapter.WALL_KEY, adapter.ROOF_KEY]:
		var cleanup: Dictionary = adapter.build_chunk_plan(prepared, Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
		_require(bool(cleanup.get("ok", false)), "Mariner complete/half cleanup construction.")
		if not bool(cleanup.get("ok", false)): continue
		var pending: Array = []
		for result: Dictionary in cleanup.records.values(): pending.append(result.node)
		var consumed: Node = null
		if not first.is_empty(): consumed = adapter.consume_record(prepared.source_records[first], cleanup).node
		var survives: Array[bool] = []
		for node: Node in pending: survives.append(node == consumed)
		adapter.free_unconsumed(cleanup)
		_require(cleanup.records.is_empty() and cleanup.pending_keys.is_empty() and adapter.plan_was_fully_consumed(cleanup), "Mariner cleanup clears complete pending maps.")
		for index in pending.size(): _require(is_instance_valid(pending[index]) == survives[index], "Mariner cleanup frees only unconsumed roots.")
		if consumed != null: consumed.free()


func _validate_mariner(wall: Node3D, roof: Node3D, adapter: Script) -> void:
	var probe := GameMain.new()
	_require(probe._mac_export_mariner_pair_valid(wall, roof, adapter), "Mariner package split/source receiver/detail/ordered-face predicate: " + adapter.SOURCE_KEY)
	probe.free()
	var prepared: Dictionary = adapter.prepare_chunk_records(_json(adapter.FACTORY.CHUNK_PATH))
	var builder := WorldChunkBuilder.new()
	var fresh: Dictionary = adapter.FACTORY.build_for_records(prepared.source_records[adapter.WALL_KEY], prepared.source_records[adapter.ROOF_KEY], Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
	_require(bool(fresh.get("ok", false)), "Mariner same-runtime pinned factory comparison: " + adapter.SOURCE_KEY)
	if not bool(fresh.get("ok", false)): return
	var original: Node3D = fresh.node
	var seen: Array[String] = []
	var channel_count := 0
	for outer: Node3D in [wall, roof]:
		for child: Node in outer.get_children():
			var before := original.get_node_or_null(NodePath(child.name))
			_require(before != null, "Mariner exact original child: " + str(child.name))
			if before == null: continue
			if child is MeshInstance3D:
				seen.append(str(child.name))
				_require(child.mesh != null and before is MeshInstance3D and before.mesh != null, "Mariner mesh pair exists.")
				if child.mesh == null or not before is MeshInstance3D or before.mesh == null: continue
				_require(child.mesh.get_class() == before.mesh.get_class() and child.mesh.get_surface_count() == 1 and before.mesh.get_surface_count() == 1 and child.transform == before.transform and child.layers == before.layers and child.cast_shadow == before.cast_shadow, "Mariner exact mesh class/partition/transform/layers/shadow: " + str(child.name))
				var a: Array = child.mesh.surface_get_arrays(0)
				var b: Array = before.mesh.surface_get_arrays(0)
				_require(a.size() == 13 and b.size() == 13 and Mesh.ARRAY_MAX == 13, "Mariner all thirteen native channels.")
				if a.size() == 13 and b.size() == 13:
					for channel in Mesh.ARRAY_MAX:
						_require(var_to_bytes(a[channel]) == var_to_bytes(b[channel]), "Mariner native channel " + str(channel) + ": " + str(child.name))
						channel_count += 1
				var an: Variant = child.mesh.surface_get_name(0) if child.mesh is ArrayMesh else null
				var bn: Variant = before.mesh.surface_get_name(0) if before.mesh is ArrayMesh else null
				_require(an == bn and _material_equal(child.get_active_material(0), before.get_active_material(0)), "Mariner guarded surface name and complete stored material/shader state: " + str(child.name))
			else:
				_require(_northern_snapshot(child) == _northern_snapshot(before), "Mariner complete nested original/detail transforms/ownership/ordered shape buffers: " + str(child.name))
	_require(seen.size() == 14 and channel_count == 182, "Mariner all fourteen meshes and 182 channel slots compared.")
	var source_units := 0
	for unit: Dictionary in _json(REGISTRY).get("units", []):
		if str(unit.get("unit_id", "")) == "physical-building:" + adapter.SOURCE_KEY:
			source_units += 1
			var accepted: Dictionary = JSON.parse_string("{\"physical-building:w96215677\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"16/213\",\"evidence_manifest_sha256\":\"2ef58e0ef4ab39375107bf4d5354b83399eceda0bc36599b7bbb5e98bb79e6b9\",\"evidence_tree_sha256\":\"70f69ef17176b2810b073f4304fd17f6bc7143a70ac031d1a20922996422661c\",\"mechanical_review_receipt_sha256\":\"c806dc1fd6f146f8573e83b3fd8ac8523d87fba1d57e8f5e9d29a066b481f3bd\",\"motion_telemetry_manifest_sha256\":\"bd5aacf373d887cddf2c25ed0788ab0286faa0c9daa7cc0e9e03a81ad744bd0e\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"03f2cf746dc931dd816f28f337b12ae9f11d7cb5ef3c3087601a46bb9df427c7\",\"review_id\":\"northern-1206-quality-candidate-2026-09-13-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"b3549c8b8616163a06c8fa2209562bda58ad9ce03ad3ae68751c9ca256b9e09a\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"6bee171a27e3a10b3f1927f332a678ec0826e982faa6085e71db525bcdb30096\"}],\"active_runtime_adapter_ids\":[\"active-adapter:mariner-1206-live:building:w96215677:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215680\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"16/213\",\"evidence_manifest_sha256\":\"892c34c422283ba7eadd3b5a8d005f34b8736e4b359ffc67ba7194a6c4fc110d\",\"evidence_tree_sha256\":\"bd06a1a34a11937410f82ad5d6903de68e8d0a1660b5a9b2d8815afeee990ea6\",\"mechanical_review_receipt_sha256\":\"03003e86b6fb4b7fb28099876e6a788e9c8596bd14f25a794d8a1adce6fd4ecd\",\"motion_telemetry_manifest_sha256\":\"98fe533ab07e2ff5f098094ad68e2b32b20712e13de75881e679eb84fb107c0f\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"4c2e64ec36a96058c8d48a7cb5f5e9c29c0e1154ff2c2db179071cc8f7553e62\",\"review_id\":\"northern-1219-quality-candidate-2026-09-13-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"f58284bed7ac7fce861a282a344bac1cdb12d6b69286d0cfbde3936f9022139b\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"754b234c8806726b70400dcd759abbed3a309fad42be12669b2cf877e6e5b415\"}],\"active_runtime_adapter_ids\":[\"active-adapter:mariner-1219-live:building:w96215680:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}}}")
			var expected: Dictionary = accepted["physical-building:" + adapter.SOURCE_KEY]
			_require((unit.get("acceptance_records", []) as Array) == expected.acceptance_records and (unit.get("active_runtime_adapter_ids", []) as Array) == expected.active_runtime_adapter_ids and expected.active_runtime_adapter_ids == [adapter.ADAPTER_ID] and (unit.get("claim_status", {}) as Dictionary) == expected.claim_status, "Mariner exact seven-role current23 record, sole adapter and claim state; capture16 product metadata remains historical.")
	_require(source_units == 1, "One immutable mariner unit identity.")
	if not _failed:
		print("MARINER_PACKAGE_ATTACHMENT: source=%s wall=%s roof=%s native_channels=182 materials=14 source_plus_detail_shapes=10 current_authority=32/213 credit=0" % [adapter.SOURCE_KEY, _measure(wall), _measure(roof)])
	original.free()


func _mounted_family(adapter: Script) -> void:
	var prepared: Dictionary = adapter.prepare_chunk_records(_json(adapter.FACTORY.CHUNK_PATH))
	_require(bool(prepared.get("ok", false)) and bool(prepared.get("contains_target", false)), "Candidate family exact supplied pair: " + adapter.SOURCE_KEY)
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var probe := GameMain.new()
	var spec: Dictionary = probe._mac_export_family_spec(adapter)
	probe.free()
	_require(not spec.is_empty(), "Known candidate identity.")
	if spec.is_empty(): return
	var counts := {"raw": [], "detail_tangents": 0}
	var raw := func(record: Dictionary, context: bool) -> Dictionary:
		counts.raw.append({"key": str(record.object_key), "is_context": context})
		return builder._build_unpaired_record(record, context)
	var tangents := func(vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> PackedFloat32Array:
		counts.detail_tangents += 1
		return builder._tangents_for(vertices, normals, uvs, indices)
	var plan: Dictionary = adapter.build_chunk_plan(prepared, raw, tangents)
	_require(bool(plan.get("ok", false)), "Candidate family package callback construction: " + adapter.SOURCE_KEY)
	if not bool(plan.get("ok", false)):
		adapter.free_unconsumed(plan)
		return
	_require(counts.raw == [{"key": adapter.WALL_KEY, "is_context": false}, {"key": adapter.ROOF_KEY, "is_context": false}] and counts.detail_tangents == int(spec.detail_tangents), "Candidate family actual raw2/unit-specific detail callbacks: " + adapter.SOURCE_KEY)
	var staging := Node3D.new()
	var pair: Dictionary = {}
	for key: String in [adapter.WALL_KEY, adapter.ROOF_KEY]:
		var record: Dictionary = prepared.source_records[key]
		var result: Dictionary
		match str(adapter.SOURCE_KEY):
			"w96215649": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215652": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215658": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			_: result = {"ok": false}
		_require(bool(result.get("ok", false)), "Candidate family real sixteenth/seventeenth/eighteenth argument dispatch: " + key)
		if bool(result.get("ok", false)):
			pair[key] = result.node
			staging.add_child(result.node)
			var measured := _measure(result.node)
			_require([result.mesh_instances, result.surfaces, result.triangles, result.static_bodies, result.shapes] == [measured.meshes, measured.surfaces, measured.triangles, measured.bodies, measured.shapes], "Candidate family direct result counters equal native descendants: " + key)
			var metadata: Dictionary = result.metadata
			_require(metadata.adapter_id == adapter.ADAPTER_ID and metadata.source_key == adapter.SOURCE_KEY and metadata.factory_calls == 1 and metadata.mapped_public_run_indices == adapter.MAPPED_RUNS and metadata.protected_run_indices == adapter.PROTECTED_RUNS, "Candidate family result factory and ownership metadata: " + key)
			_require(not metadata.partial_pair_allowed and not metadata.fallback_allowed and not metadata.stack_allowed and not metadata.recognition_accepted and metadata.package_attachment_pending and metadata.original_source_channels_and_roof_preserved and metadata.source_wall_spray_eligibility_preserved, "Candidate family unchanged fail-closed uncredited result contract: " + key)
	_require(adapter.plan_was_fully_consumed(plan) and plan.records.is_empty() and pair.size() == 2, "Candidate family pair consumed exactly once: " + adapter.SOURCE_KEY)
	_require(not bool(adapter.consume_record(prepared.source_records[adapter.WALL_KEY], plan).ok), "Candidate family duplicate consumption rejects.")
	if pair.size() == 2:
		_validate_family(pair[adapter.WALL_KEY], pair[adapter.ROOF_KEY], adapter)
	adapter.free_unconsumed(plan)
	for node: Node in pair.values(): _require(is_instance_valid(node), "Consumed candidate family roots survive pending cleanup.")
	staging.free()
	for node: Variant in pair.values(): _require(not is_instance_valid(node), "Candidate family consumed staging roots release.")
	for first: String in ["", adapter.WALL_KEY, adapter.ROOF_KEY]:
		var cleanup: Dictionary = adapter.build_chunk_plan(prepared, Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
		_require(bool(cleanup.get("ok", false)), "Candidate family complete/half cleanup construction.")
		if not bool(cleanup.get("ok", false)): continue
		var pending: Array = []
		for result: Dictionary in cleanup.records.values(): pending.append(result.node)
		var consumed: Node = null
		if not first.is_empty(): consumed = adapter.consume_record(prepared.source_records[first], cleanup).node
		var survives: Array[bool] = []
		for node: Node in pending: survives.append(node == consumed)
		adapter.free_unconsumed(cleanup)
		_require(cleanup.records.is_empty() and cleanup.pending_keys.is_empty() and adapter.plan_was_fully_consumed(cleanup), "Candidate family cleanup clears complete pending maps.")
		for index in pending.size(): _require(is_instance_valid(pending[index]) == survives[index], "Candidate family cleanup frees only unconsumed roots.")
		if consumed != null: consumed.free()


func _validate_family(wall: Node3D, roof: Node3D, adapter: Script) -> void:
	var probe := GameMain.new()
	_require(probe._mac_export_family_pair_valid(wall, roof, adapter), "Candidate family package split/source receiver/detail/ordered-face predicate: " + adapter.SOURCE_KEY)
	var spec: Dictionary = probe._mac_export_family_spec(adapter)
	probe.free()
	if spec.is_empty(): return
	var prepared: Dictionary = adapter.prepare_chunk_records(_json(adapter.FACTORY.CHUNK_PATH))
	var builder := WorldChunkBuilder.new()
	var fresh: Dictionary = adapter.FACTORY.build_for_records(prepared.source_records[adapter.WALL_KEY], prepared.source_records[adapter.ROOF_KEY], Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
	_require(bool(fresh.get("ok", false)), "Candidate family same-runtime pinned factory comparison: " + adapter.SOURCE_KEY)
	if not bool(fresh.get("ok", false)): return
	var original: Node3D = fresh.node
	var seen: Array[String] = []
	var channel_count := 0
	for outer: Node3D in [wall, roof]:
		for child: Node in outer.get_children():
			var before := original.get_node_or_null(NodePath(child.name))
			_require(before != null, "Candidate family exact original child: " + str(child.name))
			if before == null: continue
			if child is MeshInstance3D:
				seen.append(str(child.name))
				_require(child.mesh != null and before is MeshInstance3D and before.mesh != null, "Candidate family mesh pair exists.")
				if child.mesh == null or not before is MeshInstance3D or before.mesh == null: continue
				_require(child.mesh.get_class() == before.mesh.get_class() and child.mesh.get_surface_count() == 1 and before.mesh.get_surface_count() == 1 and child.transform == before.transform and child.layers == before.layers and child.cast_shadow == before.cast_shadow, "Candidate family exact mesh class/partition/transform/layers/shadow: " + str(child.name))
				var a: Array = child.mesh.surface_get_arrays(0)
				var b: Array = before.mesh.surface_get_arrays(0)
				_require(a.size() == 13 and b.size() == 13 and Mesh.ARRAY_MAX == 13, "Candidate family all thirteen native channels.")
				if a.size() == 13 and b.size() == 13:
					for channel in Mesh.ARRAY_MAX:
						_require(var_to_bytes(a[channel]) == var_to_bytes(b[channel]), "Candidate family native channel " + str(channel) + ": " + str(child.name))
						channel_count += 1
				var an: Variant = child.mesh.surface_get_name(0) if child.mesh is ArrayMesh else null
				var bn: Variant = before.mesh.surface_get_name(0) if before.mesh is ArrayMesh else null
				_require(an == bn and _material_equal(child.get_active_material(0), before.get_active_material(0)), "Candidate family guarded surface name and complete stored material/shader state: " + str(child.name))
			else:
				_require(_northern_snapshot(child) == _northern_snapshot(before), "Candidate family complete nested original/detail transforms/ownership/ordered shape buffers: " + str(child.name))
	_require(seen.size() == int(spec.meshes) and channel_count == int(spec.channels), "Candidate family all target-specific meshes and thirteen channel slots each compared.")
	var source_units := 0
	for unit: Dictionary in _json(REGISTRY).get("units", []):
		if str(unit.get("unit_id", "")) == "physical-building:" + adapter.SOURCE_KEY:
			source_units += 1
			var accepted: Dictionary = JSON.parse_string("{\"physical-building:w96215649\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"18/213\",\"evidence_manifest_sha256\":\"e639c2fe4ca2beebdd067a8d804d231ba4e4a9e55e4d85699496533479267de2\",\"evidence_tree_sha256\":\"0c46621cf3d43660a7e7d8168dcdf0be5556d96b5ff1a63b0715295311565d35\",\"mechanical_review_receipt_sha256\":\"6f67a10d85551c5e4226ff47edcd15a15ce25f3a179ffa0e3670d3c0981be3fb\",\"motion_telemetry_manifest_sha256\":\"e78ac76b320df4869bc882a52e5e37ad56a863f5e99734d9b45e2d84764a6424\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"276b71133a8ae9c1f0fd8caecdbd0365f16c3ca4655d49e99149bbaec61b0ae0\",\"review_id\":\"northern-1212-quality-candidate-2026-09-14-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"bbc33d45ea0708df973adc24897b27ceaa052117c4f002546df64b2fdb30ef3d\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"e094b27c9dc69797035270a9acfedcb4db9832338f4915178e101f05621b49af\"}],\"active_runtime_adapter_ids\":[\"active-adapter:mariner-1212-live:building:w96215649:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215652\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"18/213\",\"evidence_manifest_sha256\":\"410d90ee3599491993fddcc0ed8accea3de05bb4e905be9076078629b36f7835\",\"evidence_tree_sha256\":\"1d2e5d2682e0b72c9c81b5962680e11c9cdba200d0ab13b11db1c6dac54f1aef\",\"mechanical_review_receipt_sha256\":\"923517f30c75e83af49c039111fdac548d8a20c0486cdf202863e04cca41c3ef\",\"motion_telemetry_manifest_sha256\":\"94994da3f3db23d5bc81d4892e7ddcbafe91228aa891890198b9afee0339e961\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"dbef975d3b3afedac4694ea49c57f4e98e50a41f67ed2a61621dae3cc0c12176\",\"review_id\":\"northern-1220-quality-candidate-2026-09-14-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"ca45fe7f855fb98ecadecddf7a04e8b9e13f73355bed128cfc4c8ef83a13fc1c\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"db006b21c253ea7dbcc937ff6ba5bf7805894f9b00b8ef6164396ee9f6b3af23\"}],\"active_runtime_adapter_ids\":[\"active-adapter:bayside-1220-live:building:w96215652:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215658\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"18/213\",\"evidence_manifest_sha256\":\"640768775dc2090c5742eb1b8468f0a9992086fbe06cca8ae8f5982309b20ee6\",\"evidence_tree_sha256\":\"7da899b63a2f906a643ac3eeb3a92a793fa3b502e9fa60f395b58fe60139d3e0\",\"mechanical_review_receipt_sha256\":\"d45db6575672f8c713ce96ec41d577d507722a57c14417657f7c2cc564f70f81\",\"motion_telemetry_manifest_sha256\":\"be716635b72e105c8440c51836735e149360f20eda1fdc95b9a0bfd83f39a6e2\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"2e57bb89f4e646abc95a7db1a7cea82100c058121ad6755ff08edd1fd6403be2\",\"review_id\":\"northern-1239-quality-candidate-2026-09-14-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"f46366f21b1cc5ed5fb2a230fd35cdc144d02b24833292b9c1ad617f58191c55\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"47f2d83b04b14b988f9b72c22b8384120201eba933a0a9fd7ca1dd7163eda22c\"}],\"active_runtime_adapter_ids\":[\"active-adapter:northpoint-1239-live:building:w96215658:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}}}")
			var expected: Dictionary = accepted["physical-building:" + adapter.SOURCE_KEY]
			_require((unit.get("acceptance_records", []) as Array) == expected.acceptance_records and (unit.get("active_runtime_adapter_ids", []) as Array) == expected.active_runtime_adapter_ids and expected.active_runtime_adapter_ids == [adapter.ADAPTER_ID] and (unit.get("claim_status", {}) as Dictionary) == expected.claim_status, "Family exact seven-role record retained in current26, sole adapter and claim state; capture18 metadata remains historical.")
	_require(source_units == 1, "One immutable candidate family unit identity.")
	if not _failed:
		print("FAMILY_PACKAGE_ATTACHMENT: source=%s wall=%s roof=%s native_channels=%d materials=%d source_plus_detail_shapes=%d current_authority=32/213 credit=0" % [adapter.SOURCE_KEY, _measure(wall), _measure(roof), spec.channels, spec.meshes, spec.shapes])
	original.free()


func _mounted_projected_family(adapter: Script) -> void:
	var prepared: Dictionary = adapter.prepare_chunk_records(_json(adapter.FACTORY.CHUNK_PATH))
	_require(bool(prepared.get("ok", false)) and bool(prepared.get("contains_target", false)), "Candidate family exact supplied pair: " + adapter.SOURCE_KEY)
	if _failed: return
	var builder := WorldChunkBuilder.new()
	var probe := GameMain.new()
	var spec: Dictionary = probe._mac_export_projected_family_spec(adapter)
	probe.free()
	_require(not spec.is_empty(), "Known candidate identity.")
	if spec.is_empty(): return
	var counts := {"raw": [], "detail_tangents": 0}
	var raw := func(record: Dictionary, context: bool) -> Dictionary:
		counts.raw.append({"key": str(record.object_key), "is_context": context})
		return builder._build_unpaired_record(record, context)
	var tangents := func(vertices: PackedVector3Array, normals: PackedVector3Array, uvs: PackedVector2Array, indices: PackedInt32Array) -> PackedFloat32Array:
		counts.detail_tangents += 1
		return builder._tangents_for(vertices, normals, uvs, indices)
	var plan: Dictionary = adapter.build_chunk_plan(prepared, raw, tangents)
	_require(bool(plan.get("ok", false)), "Candidate family package callback construction: " + adapter.SOURCE_KEY)
	if not bool(plan.get("ok", false)):
		adapter.free_unconsumed(plan)
		return
	_require(counts.raw == [{"key": adapter.WALL_KEY, "is_context": false}, {"key": adapter.ROOF_KEY, "is_context": false}] and counts.detail_tangents == int(spec.detail_tangents), "Candidate family actual raw2/unit-specific detail callbacks: " + adapter.SOURCE_KEY)
	var staging := Node3D.new()
	var pair: Dictionary = {}
	for key: String in [adapter.WALL_KEY, adapter.ROOF_KEY]:
		var record: Dictionary = prepared.source_records[key]
		var result: Dictionary
		match str(adapter.SOURCE_KEY):
			"w96215661": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215653": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215651": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215659": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215666": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215673": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215674": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215682": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215688": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215670": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			"w96215685": result = builder._build_record(record, false, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, plan)
			_: result = {"ok": false}
		_require(bool(result.get("ok", false)), "Candidate family real per-source supplied-plan argument dispatch: " + key)
		if bool(result.get("ok", false)):
			pair[key] = result.node
			staging.add_child(result.node)
			var measured := _measure(result.node)
			_require([result.mesh_instances, result.surfaces, result.triangles, result.static_bodies, result.shapes] == [measured.meshes, measured.surfaces, measured.triangles, measured.bodies, measured.shapes], "Candidate family direct result counters equal native descendants: " + key)
			var metadata: Dictionary = result.metadata
			_require(metadata.adapter_id == adapter.ADAPTER_ID and metadata.source_key == adapter.SOURCE_KEY and metadata.factory_calls == 1 and metadata.mapped_public_run_indices == adapter.MAPPED_RUNS and metadata.protected_run_indices == adapter.PROTECTED_RUNS, "Candidate family result factory and ownership metadata: " + key)
			if adapter in [A1234, A1215]: _candidate_result_scope(metadata, adapter)
			_require(not metadata.partial_pair_allowed and not metadata.fallback_allowed and not metadata.stack_allowed and not metadata.recognition_accepted and metadata.package_attachment_pending and metadata.original_source_channels_and_roof_preserved and metadata.source_wall_spray_eligibility_preserved, "Candidate family unchanged fail-closed uncredited result contract: " + key)
	_require(adapter.plan_was_fully_consumed(plan) and plan.records.is_empty() and pair.size() == 2, "Candidate family pair consumed exactly once: " + adapter.SOURCE_KEY)
	_require(not bool(adapter.consume_record(prepared.source_records[adapter.WALL_KEY], plan).ok), "Candidate family duplicate consumption rejects.")
	if pair.size() == 2:
		_validate_projected_family(pair[adapter.WALL_KEY], pair[adapter.ROOF_KEY], adapter)
	adapter.free_unconsumed(plan)
	for node: Node in pair.values(): _require(is_instance_valid(node), "Consumed candidate family roots survive pending cleanup.")
	staging.free()
	for node: Variant in pair.values(): _require(not is_instance_valid(node), "Candidate family consumed staging roots release.")
	for first: String in ["", adapter.WALL_KEY, adapter.ROOF_KEY]:
		var cleanup: Dictionary = adapter.build_chunk_plan(prepared, Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
		_require(bool(cleanup.get("ok", false)), "Candidate family complete/half cleanup construction.")
		if not bool(cleanup.get("ok", false)): continue
		var pending: Array = []
		for result: Dictionary in cleanup.records.values(): pending.append(result.node)
		var consumed: Node = null
		if not first.is_empty(): consumed = adapter.consume_record(prepared.source_records[first], cleanup).node
		var survives: Array[bool] = []
		for node: Node in pending: survives.append(node == consumed)
		adapter.free_unconsumed(cleanup)
		_require(cleanup.records.is_empty() and cleanup.pending_keys.is_empty() and adapter.plan_was_fully_consumed(cleanup), "Candidate family cleanup clears complete pending maps.")
		for index in pending.size(): _require(is_instance_valid(pending[index]) == survives[index], "Candidate family cleanup frees only unconsumed roots.")
		if consumed != null: consumed.free()


func _validate_projected_family(wall: Node3D, roof: Node3D, adapter: Script) -> void:
	var probe := GameMain.new()
	_require(probe._mac_export_projected_family_pair_valid(wall, roof, adapter), "Candidate family package split/source receiver/detail/ordered-face predicate: " + adapter.SOURCE_KEY)
	var spec: Dictionary = probe._mac_export_projected_family_spec(adapter)
	probe.free()
	if spec.is_empty(): return
	if adapter in [A1234, A1215, A1232, A1241, A1221, A1240, A1397, A1226]: _candidate_study_measurements(wall, roof, adapter)
	var prepared: Dictionary = adapter.prepare_chunk_records(_json(adapter.FACTORY.CHUNK_PATH))
	var builder := WorldChunkBuilder.new()
	var fresh: Dictionary = adapter.FACTORY.build_for_records(prepared.source_records[adapter.WALL_KEY], prepared.source_records[adapter.ROOF_KEY], Callable(builder, "_build_unpaired_record"), Callable(builder, "_tangents_for"))
	_require(bool(fresh.get("ok", false)), "Candidate family same-runtime pinned factory comparison: " + adapter.SOURCE_KEY)
	if not bool(fresh.get("ok", false)): return
	var original: Node3D = fresh.node
	var seen: Array[String] = []
	var channel_count := 0
	for outer: Node3D in [wall, roof]:
		for child: Node in outer.get_children():
			var before := original.get_node_or_null(NodePath(child.name))
			_require(before != null, "Candidate family exact original child: " + str(child.name))
			if before == null: continue
			if child is MeshInstance3D:
				seen.append(str(child.name))
				_require(child.mesh != null and before is MeshInstance3D and before.mesh != null, "Candidate family mesh pair exists.")
				if child.mesh == null or not before is MeshInstance3D or before.mesh == null: continue
				_require(child.mesh.get_class() == before.mesh.get_class() and child.mesh.get_surface_count() == 1 and before.mesh.get_surface_count() == 1 and child.transform == before.transform and child.layers == before.layers and child.cast_shadow == before.cast_shadow, "Candidate family exact mesh class/partition/transform/layers/shadow: " + str(child.name))
				var a: Array = child.mesh.surface_get_arrays(0)
				var b: Array = before.mesh.surface_get_arrays(0)
				_require(a.size() == 13 and b.size() == 13 and Mesh.ARRAY_MAX == 13, "Candidate family all thirteen native channels.")
				if a.size() == 13 and b.size() == 13:
					for channel in Mesh.ARRAY_MAX:
						_require(var_to_bytes(a[channel]) == var_to_bytes(b[channel]), "Candidate family native channel " + str(channel) + ": " + str(child.name))
						channel_count += 1
				var an: Variant = child.mesh.surface_get_name(0) if child.mesh is ArrayMesh else null
				var bn: Variant = before.mesh.surface_get_name(0) if before.mesh is ArrayMesh else null
				_require(an == bn and _material_equal(child.get_active_material(0), before.get_active_material(0)), "Candidate family guarded surface name and complete stored material/shader state: " + str(child.name))
			else:
				_require(_northern_snapshot(child) == _northern_snapshot(before), "Candidate family complete nested original/detail transforms/ownership/ordered shape buffers: " + str(child.name))
	_require(seen.size() == int(spec.meshes) and channel_count == int(spec.channels), "Candidate family all target-specific meshes and thirteen channel slots each compared.")
	var source_units := 0
	for unit: Dictionary in _json(REGISTRY).get("units", []):
		if str(unit.get("unit_id", "")) == "physical-building:" + adapter.SOURCE_KEY:
			source_units += 1
			if adapter in [A1397, A1226]:
				_require((unit.get("acceptance_records", []) as Array).is_empty() and (unit.get("active_runtime_adapter_ids", []) as Array).is_empty() and str((unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "not_evaluated", "Candidate units remain unaccepted and uncredited.")
				continue
			# Actual serialized seven-role records from the successful A003 compiled registry.
			var accepted: Dictionary = JSON.parse_string("{\"physical-building:w96215651\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"23/213\",\"evidence_manifest_sha256\":\"497ce96296ada0265a26c4d24215db320b278cff8883be00b5d637a94d2cfd64\",\"evidence_tree_sha256\":\"3c30e9c73026a885f2ee2b3941b28e7ed6be799571c58fa733d2e209adfad7fe\",\"mechanical_review_receipt_sha256\":\"669f108baf4c343f766da111c808232e6b4b611d13cf919526372e54f8642d34\",\"motion_telemetry_manifest_sha256\":\"8205cf8904929d56d9e90842922a6be37cf64869f283c60aac666e42e571c236\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"1da322cc863b923b4befee6eac8f3876c1fa0360a1848527c88cba774c935769\",\"review_id\":\"northern-1202-quality-candidate-2026-09-14-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"6a7813fc1a94f816bd01f55f6901a61f7d421b67e085663b6e51ad865408754e\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"4de165e49df045101b1fd7156f0f7595c0026617db255ab3c23412b1a4424081\"}],\"active_runtime_adapter_ids\":[\"active-adapter:mariner-1202-live:building:w96215651:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215653\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"23/213\",\"evidence_manifest_sha256\":\"f240c0a442a66cdb5e20fffa4883e2b9098ce681d0fdefa3c30e846e376d517b\",\"evidence_tree_sha256\":\"34e252f76805cd5e152fd58056f95852ba5c4ebfdc2e73ceeb20f1410c74eadb\",\"mechanical_review_receipt_sha256\":\"45cf53232bcb34f4bf43b2370a7ce0e84ade628dc23e9aa7a8439f70eb102c03\",\"motion_telemetry_manifest_sha256\":\"c45ad15c677f1413d106695f8a1c6e339c0b6da6f4fb67eea0d9b6ae53b64018\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"802e3287f84f0363a688d35454e88aebef7d34b93db88b88d16785311ec3d7d4\",\"review_id\":\"northern-1227-quality-candidate-2026-09-14-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"8957bff439a37e22880af8b0df5c6641e348bb19e13207bd65ac8e94cb1484ad\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"a28bf431f24e58cc147b3adc6df9983784f68d6f0335c61bea3bda7d02e0cfa8\"}],\"active_runtime_adapter_ids\":[\"active-adapter:northpoint-1227-live:building:w96215653:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215659\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"23/213\",\"evidence_manifest_sha256\":\"29b8208ce1d2061557f5e440b73b29f19d9832f6341ce55d6a00f16d71abdb75\",\"evidence_tree_sha256\":\"f8941af510bc00e6e14ea5125f06b7503514b674449e84a543ffdc1765f64852\",\"mechanical_review_receipt_sha256\":\"48995f50883a6ff1d36af054f545dd0cd7ff9739e68749d5efcce34c119701d2\",\"motion_telemetry_manifest_sha256\":\"d5aa947c9f8ccd189bdbfc1fb93089b3423ff39dc082da017b5df46bdabe7ce0\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"ee10c9345a74c96e2c85b919679405e8d3ec08a296994895ec357dafd2d3fde1\",\"review_id\":\"northern-1234-quality-candidate-2026-09-22-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"607c60defc1825ff28afa0dd591d50e42669a140496ea06afaa14699209e1ef4\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"9ac0894c8d7f52729f25294d24b666f97a9a8ebca91a4ed7892e766c99a8dae9\"}],\"active_runtime_adapter_ids\":[\"active-adapter:northpoint-1234-live:building:w96215659:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215661\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"23/213\",\"evidence_manifest_sha256\":\"c9bdee01510d7e0c2f43be4c454b154437009583b2c59c15ba211f07ee16f259\",\"evidence_tree_sha256\":\"4870b6e92d8d9d42c7107a27f38af1f115f39cd934e920d297363c018d3d2822\",\"mechanical_review_receipt_sha256\":\"ec1e740bd93a8325094811bf634d90d43c672574a002a90c96a1a454662996cf\",\"motion_telemetry_manifest_sha256\":\"ac2950c05d8472b5a8edb0ce2f7b4437159d6af963145dfd142ec5bc59019b98\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"a6ea228918898454c56fd5aebe1affbd94d0bc7c1878c966c14fc704409e028b\",\"review_id\":\"northern-1222-quality-candidate-2026-09-14-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"20a5a14b31c9918f7e9e4c3884c1ca3deef55af1ccd5720c4c9d581710c42f76\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"0976e8393145f40ce9e07c861bdc1a032f15b0cf70e6c984244318e2adfb92d3\"}],\"active_runtime_adapter_ids\":[\"active-adapter:bayside-1222-live:building:w96215661:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215666\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"23/213\",\"evidence_manifest_sha256\":\"685725ca0d2454610a5e304dc5fef6c968fc35cfb98819b0a5a88c64dbfdf084\",\"evidence_tree_sha256\":\"7e192e071997d82a527192e787ae7290f5ef4c18c2417afe57348f0da49e35fe\",\"mechanical_review_receipt_sha256\":\"b211c1ad80d9c864d47dc9933985d661af01d25b6bc0d0d211d59bf8edd58feb\",\"motion_telemetry_manifest_sha256\":\"7ed10c2427be78afaa26e950c76cb54ccbec6e73d1a4bc3781b7fb1b9e5d9737\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"191674762a5d82a363698fb5155dc659cba5cc06f20294b26efd1a8789af8a7e\",\"review_id\":\"northern-1215-quality-candidate-2026-09-22-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"5c6678ebd09028ee5f17c7ada899aaa93aff0baf8bc6dea05f9606638b546b23\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"d25f30eff4d7d0fd4f7c0de034c9f2f88e34f93ce0f7b35e8de7e1c5c9f76462\"}],\"active_runtime_adapter_ids\":[\"active-adapter:bayside-1215-live:building:w96215666:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215673\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"26/213\",\"evidence_manifest_sha256\":\"d2d9bd3d7f643d92b45d4c1ca974892d3b35210ae2d2cfe55b89fb4afb94df26\",\"evidence_tree_sha256\":\"c323d879c100e3ac1898905a9841e7f52cc4a76022e7329638ae7feeb586739d\",\"mechanical_review_receipt_sha256\":\"2560c1e1032fd997a2cf8db74de48d0430d9bb0fb61165cc09312efba5e9af5f\",\"motion_telemetry_manifest_sha256\":\"1fd9e52c06c062e48dfc3d6489dfaba4350ba1413a97923f9a44371b052dad39\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"f38bbb66dce45b62bdb82705335b55547f571992a8389f6b8346b16f56e32c1f\",\"review_id\":\"northern-1232-quality-candidate-2026-09-22-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"1cbb4737ed14190e9f6a744b152eaaeddf8d18c39f827cfab784ec94f07c16be\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"26d44f6abccabc4c3075a214a22feff4ba4f6d5b2f6b1b2815d4c32301c37577\"}],\"active_runtime_adapter_ids\":[\"active-adapter:northpoint-1232-live:building:w96215673:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215674\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"28/213\",\"evidence_manifest_sha256\":\"465fd62a4b0ce93e7185b6eb17bdf50ede9127e60c492e59848d830d1fb0d2f7\",\"evidence_tree_sha256\":\"4b293afae85d79015d9f6c0a0b22dff50962db7bf8b05d9f4ba52e152cb13a32\",\"mechanical_review_receipt_sha256\":\"6c956cd7f3b7502ab73505d11297efa68d365f7f393f8419fd9293fb71a99cb9\",\"motion_telemetry_manifest_sha256\":\"c2e401e59485819a039b4b40bf0f025edabf9691673b179e89c338927a10939c\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"c7a8caf732d9d50ba481b3a889ab9c8aff72833fb2277c56fb997d7af3baef98\",\"review_id\":\"northern-1241-quality-candidate-2026-09-22-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"b89b6e90ed0cd33dcf4a540a62965a71ff75c3d8d2eb9ec1e8368b6e3016f869\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"690e653a17e8adcebe8908ffa06c8a6dd7b2c5e6886d42f9415e1b03f2ecfd9a\"}],\"active_runtime_adapter_ids\":[\"active-adapter:northpoint-1241-live:building:w96215674:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215682\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"28/213\",\"evidence_manifest_sha256\":\"cb80718812047da42fb907917cafe4ce59a15eada7b2dc9aaef1b26b56697970\",\"evidence_tree_sha256\":\"b3861383f25ceb1f14f6f068dcabf145b3afe9fb5ba8b0056f1e6b79a145e757\",\"mechanical_review_receipt_sha256\":\"76517f928240abbe44a989e29546135711039869f595b0d7f6073a3cf8262153\",\"motion_telemetry_manifest_sha256\":\"cffac7d9d8bda08c1651fa0db0f4969ddf9de5ce9065548dd25e1aab415e571f\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"80140a7a02f241033157e6f22813a98b56ddf718193298ee0237f040562d8885\",\"review_id\":\"northern-1221-quality-candidate-2026-09-22-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"235ae67b88d48acccd234af320e5a2c439318f9bff2fa1af66744858a01cb41f\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"a00772f32f2b9a68adc9607638b4045bb1abafa6455c906a718e6e9cc6ef2259\"}],\"active_runtime_adapter_ids\":[\"active-adapter:mariner-1221-live:building:w96215682:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}},\"physical-building:w96215688\":{\"acceptance_records\":[{\"capture_time_recognition_metric\":\"31/213\",\"evidence_manifest_sha256\":\"35ca950b839ba5337ec6aa1afa23c3a41b541ddbcc72d8cd948fd3ff945f357e\",\"evidence_tree_sha256\":\"d272fe5677097e67016ea21af2e9eb5e9a5daff69ad7f86deb1d343b02b7e18c\",\"mechanical_review_receipt_sha256\":\"0a6727056299a7bbf91fc97137ff794d5350128c9b3f15276f7680de9aa921d3\",\"motion_telemetry_manifest_sha256\":\"6940be3303a7bb398e89594dbbe029913b6199836e96b58ca5ed6f8cfdab6d3d\",\"numerator_effect\":1,\"package_verification_receipt_sha256\":\"aa9865bc070916b027cb58759259bd8ee0b27d1ca36ac413360d4b9d261c1ad4\",\"review_id\":\"northern-1240-quality-candidate-2026-09-22-001\",\"review_kind\":\"independent_reference_recognition\",\"review_receipt_sha256\":\"deee84ad808e2a740f79f3c796b87c18b242e18f005a902646d3645d9c580939\",\"status\":\"accept\",\"visual_motion_manifest_sha256\":\"cef4880c25f45a6d11699843dce565efd2620fc48a0904aa5af2e6f4aa8b2b9e\"}],\"active_runtime_adapter_ids\":[\"active-adapter:northpoint-1240-live:building:w96215688:wall\"],\"claim_status\":{\"as_built_fidelity\":\"unclaimed\",\"game_distinctive\":\"not_evaluated\",\"receiver_complete\":\"verified\",\"reference_recognizable\":\"accepted\"}}}")
			var unit_id: String = "physical-building:" + adapter.SOURCE_KEY
			_require(accepted.size() == 9 and accepted.has(unit_id), "Exact nine current32 accepted projected records must be bound before execution.")
			if not accepted.has(unit_id): continue
			var expected: Dictionary = accepted[unit_id]
			_require((unit.get("acceptance_records", []) as Array) == expected.acceptance_records and (unit.get("active_runtime_adapter_ids", []) as Array) == expected.active_runtime_adapter_ids and expected.active_runtime_adapter_ids == [adapter.ADAPTER_ID] and (unit.get("claim_status", {}) as Dictionary) == expected.claim_status, "Projected family exact seven-role current32 record, sole adapter and claim state; capture23 metadata remains historical.")
	_require(source_units == 1, "One immutable candidate family unit identity.")
	if not _failed:
		print("PROJECTED_FAMILY_PACKAGE_ATTACHMENT: source=%s wall=%s roof=%s native_channels=%d materials=%d source_plus_detail_shapes=%d current_authority=32/213 credit=0" % [adapter.SOURCE_KEY, _measure(wall), _measure(roof), spec.channels, spec.meshes, spec.shapes])
	original.free()


func _candidate_result_scope(metadata: Dictionary, adapter: Script) -> void:
	if adapter == A1234:
		_require(metadata.get("continuity_run_indices", []) == [0] and metadata.get("partial_run_20_observed_fraction", -1.0) == 0.3293396850039768 and metadata.get("partial_run_20_hidden_tail_protected", false) == true, "1234 continuity and protected partial run20 result scope.")

	elif adapter == A1215:
		_require(metadata.get("partial_run_ownership", {}) == {"5": {"skin_fraction_interval": [0.0,0.5], "unestablished_outer_half_protected": true}, "19": {"skin_fraction_interval": [0.15,1.0], "cropped_outer_endpoint_protected": true}}, "1215 protected partial run5/run19 result scope.")

func _candidate_study_measurements(wall: Node3D, roof: Node3D, adapter: Script) -> void:
	# Independent frozen study receipt counts, not a copy of the runtime factory output.
	var batches: Dictionary = {}
	var wall_expected: Dictionary = {}
	var roof_expected: Dictionary = {}
	var physical_names: Array = []
	if adapter == A1234:
		batches = {"ExactOriginalWallSurfaces": 52, "ExactSourceNeutralRoof": 16, "ObservedPublicRoof": 100, "CarportRoof": 12, "CarportPosts": 144, "NearHorizontalSiding": 156, "ProjectedUpperSiding": 6, "ProjectedUpperClosures": 30, "PaleCompleteTrim": 1908, "BlueOpaqueGlazing": 144, "DarkOpaqueGlazing": 120, "BlueGrayClosedDoors": 36, "PlumClosedDoors": 36, "LocalPrivacyScreens": 1800, "PaleDrainageAndFascia": 504, "DoorHardware": 72, "DrapedEntryPaths": 80, "FootwaySurface": 36, "ParkingSurface": 248}
		wall_expected = {"meshes": 18, "surfaces": 18, "triangles": 5484, "bodies": 3, "shapes": 14}
		roof_expected = {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}
		physical_names = ["ObservedPublicRoof", "CarportRoof", "CarportPosts", "ProjectedUpperClosures", "PaleCompleteTrim", "BlueOpaqueGlazing", "DarkOpaqueGlazing", "BlueGrayClosedDoors", "PlumClosedDoors", "LocalPrivacyScreens", "PaleDrainageAndFascia", "DoorHardware"]
	elif adapter == A1215:
		batches = {"ExactOriginalWallSurfaces": 40, "ExactSourceNeutralRoof": 10, "ObservedPublicRoof": 100, "CarportRoof": 12, "CarportPosts": 168, "NearHorizontalSiding": 84, "ProjectedUpperSiding": 6, "ProjectedUpperClosures": 30, "PaleCompleteTrim": 1584, "BlueOpaqueGlazing": 120, "DarkOpaqueGlazing": 96, "BlueGrayClosedDoors": 60, "LocalPrivacyScreens": 1500, "PaleDrainageAndFascia": 504, "DoorHardware": 60, "DrapedEntryPaths": 76, "FootwaySurface": 28, "ParkingSurface": 268}
		wall_expected = {"meshes": 17, "surfaces": 17, "triangles": 4736, "bodies": 3, "shapes": 13}
		roof_expected = {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1}
		physical_names = ["ObservedPublicRoof", "CarportRoof", "CarportPosts", "ProjectedUpperClosures", "PaleCompleteTrim", "BlueOpaqueGlazing", "DarkOpaqueGlazing", "BlueGrayClosedDoors", "LocalPrivacyScreens", "PaleDrainageAndFascia", "DoorHardware"]
	elif adapter == A1232:
		batches = {"ExactOriginalWallSurfaces": 48, "ExactSourceNeutralRoof": 16, "ObservedPublicRoof": 36, "CarportRoof": 12, "CarportPosts": 156, "CarportFascia": 12, "NearHorizontalSiding": 108, "ProjectedUpperSiding": 6, "ProjectedUpperClosures": 30, "PaleCompleteTrim": 972, "BlueOpaqueGlazing": 96, "DarkOpaqueGlazing": 24, "BlueGrayClosedDoors": 48, "LocalPrivacyScreens": 516, "PaleDrainageAndFascia": 216, "DoorHardware": 48, "DrapedEntryPaths": 56, "FootwaySurface": 28, "ParkingSurface": 148}
		wall_expected = {"meshes": 18, "surfaces": 18, "triangles": 2560, "bodies": 3, "shapes": 14}
		roof_expected = {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}
		physical_names = ["ObservedPublicRoof", "CarportRoof", "CarportPosts", "CarportFascia", "ProjectedUpperClosures", "PaleCompleteTrim", "BlueOpaqueGlazing", "DarkOpaqueGlazing", "BlueGrayClosedDoors", "LocalPrivacyScreens", "PaleDrainageAndFascia", "DoorHardware"]
	elif adapter == A1241:
		batches = {"ExactOriginalWallSurfaces": 52, "ExactSourceNeutralRoof": 16, "ObservedPublicRoof": 36, "CarportRoof": 12, "CarportPosts": 204, "CarportFascia": 12, "NearHorizontalSiding": 132, "ProjectedUpperSiding": 6, "ProjectedUpperClosures": 30, "PaleCompleteTrim": 1152, "BlueOpaqueGlazing": 108, "DarkOpaqueGlazing": 36, "MaroonClosedDoors": 60, "LocalPrivacyScreens": 528, "PaleDrainageAndFascia": 216, "DoorHardware": 60, "DrapedEntryPaths": 60, "FootwaySurface": 28, "ParkingSurface": 684}
		wall_expected = {"meshes": 18, "surfaces": 18, "triangles": 3416, "bodies": 3, "shapes": 14}
		roof_expected = {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}
		physical_names = ["ObservedPublicRoof", "CarportRoof", "CarportPosts", "CarportFascia", "ProjectedUpperClosures", "PaleCompleteTrim", "BlueOpaqueGlazing", "DarkOpaqueGlazing", "MaroonClosedDoors", "LocalPrivacyScreens", "PaleDrainageAndFascia", "DoorHardware"]
	elif adapter == A1221:
		batches = {"ExactOriginalWallSurfaces": 52, "ExactSourceNeutralRoof": 16, "ObservedPublicRoof": 36, "CarportRoof": 12, "CarportPosts": 204, "CarportFascia": 12, "NearHorizontalSiding": 156, "ProjectedUpperSiding": 6, "ProjectedUpperClosures": 30, "PaleCompleteTrim": 1188, "BlueOpaqueGlazing": 120, "DarkOpaqueGlazing": 36, "MaroonClosedDoors": 48, "LocalPrivacyScreens": 792, "PaleDrainageAndFascia": 216, "DoorHardware": 48, "DrapedEntryPaths": 48, "FootwaySurface": 28, "ParkingSurface": 140, "PlantedFrontage": 184}
		wall_expected = {"meshes": 19, "surfaces": 19, "triangles": 3356, "bodies": 3, "shapes": 14}
		roof_expected = {"meshes": 1, "surfaces": 1, "triangles": 16, "bodies": 1, "shapes": 1}
		physical_names = ["ObservedPublicRoof", "CarportRoof", "CarportPosts", "CarportFascia", "ProjectedUpperClosures", "PaleCompleteTrim", "BlueOpaqueGlazing", "DarkOpaqueGlazing", "MaroonClosedDoors", "LocalPrivacyScreens", "PaleDrainageAndFascia", "DoorHardware"]
	elif adapter == A1240:
		batches = {"ExactOriginalWallSurfaces":56,"ExactSourceNeutralRoof":16,"ObservedPublicRoof":36,"CarportRoof":12,"CarportPosts":180,"CarportFascia":12,"NearHorizontalSiding":108,"ProjectedUpperSiding":6,"ProjectedUpperClosures":30,"PaleCompleteTrim":1224,"BlueOpaqueGlazing":168,"MaroonClosedDoors":36,"LocalPrivacyScreens":768,"PaleDrainageAndFascia":72,"DoorHardware":36,"DrapedEntryPaths":36,"FootwaySurface":28,"ParkingSurface":232}
		wall_expected = {"meshes":17,"surfaces":17,"triangles":3040,"bodies":3,"shapes":14}
		roof_expected = {"meshes":1,"surfaces":1,"triangles":16,"bodies":1,"shapes":1}
		physical_names = ["ObservedPublicRoof","CarportRoof","CarportPosts","CarportFascia","ProjectedUpperClosures","PaleCompleteTrim","BlueOpaqueGlazing","DarkOpaqueGlazing","MaroonClosedDoors","LocalPrivacyScreens","PaleDrainageAndFascia","DoorHardware"]
	elif adapter == A1397:
		batches = {"ExactOriginalWallSurfaces":76,"ExactSourceNeutralRoof":22,"ObservedPublicRoof":48,"NearHorizontalSiding":216,"ProjectedUpperSiding":8,"ProjectedUpperClosures":40,"PaleCompleteTrim":1800,"BlueOpaqueGlazing":204,"DarkOpaqueGlazing":48,"MaroonClosedDoors":48,"LocalPrivacyScreens":900,"PaleDrainageAndFascia":720,"DoorHardware":48,"DrapedEntryPaths":56,"FootwaySurface":44}
		wall_expected = {"meshes":14,"surfaces":14,"triangles":4256,"bodies":3,"shapes":11}
		roof_expected = {"meshes":1,"surfaces":1,"triangles":22,"bodies":1,"shapes":1}
		physical_names = ["ObservedPublicRoof","ProjectedUpperClosures","PaleCompleteTrim","BlueOpaqueGlazing","DarkOpaqueGlazing","MaroonClosedDoors","LocalPrivacyScreens","PaleDrainageAndFascia","DoorHardware"]
	elif adapter == A1226:
		batches = {"ExactOriginalWallSurfaces":52,"ExactSourceNeutralRoof":14,"ShallowStoryBands":48,"ObservedPublicRoof":48,"NearHorizontalSiding":96,"ProjectedUpperSiding":8,"ProjectedUpperClosures":40,"PaleCompleteTrim":1512,"BlueOpaqueGlazing":156,"DarkOpaqueGlazing":48,"MaroonClosedDoors":48,"LocalPrivacyScreens":600,"PaleDrainageAndFascia":672,"DoorHardware":48,"DrapedEntryPaths":56,"FootwaySurface":36}
		wall_expected = {"meshes":15,"surfaces":15,"triangles":3468,"bodies":3,"shapes":12}
		roof_expected = {"meshes":1,"surfaces":1,"triangles":14,"bodies":1,"shapes":1}
		physical_names = ["ObservedPublicRoof","ShallowStoryBands","ProjectedUpperClosures","PaleCompleteTrim","BlueOpaqueGlazing","DarkOpaqueGlazing","MaroonClosedDoors","LocalPrivacyScreens","PaleDrainageAndFascia","DoorHardware"]
	_require(_measure(wall) == wall_expected and _measure(roof) == roof_expected, "Candidate study-bound exact split counts: " + adapter.SOURCE_KEY)
	var measured_batches: Dictionary = {}
	for outer: Node3D in [wall, roof]:
		for child: Node in outer.get_children():
			if child is MeshInstance3D:
				_require(not measured_batches.has(str(child.name)), "Candidate unique mesh name.")
				measured_batches[str(child.name)] = _measure(child).triangles
	_require(measured_batches == batches, "Candidate exact study per-mesh triangle inventory: " + adapter.SOURCE_KEY)
	var body := wall.get_node_or_null("PhysicalDetails_NoSprayReceiver") as StaticBody3D
	_require(body != null, "Candidate rejecting detail body exists.")
	if body != null:
		var names: Array = []
		for child: Node in body.get_children(): names.append(str(child.name))
		_require(names == physical_names, "Candidate exact study ordered physical partitions: " + adapter.SOURCE_KEY)
