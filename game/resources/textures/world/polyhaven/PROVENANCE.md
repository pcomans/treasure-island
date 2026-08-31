# Poly Haven world-material micro-bundle

Acquired 2026-08-29 UTC from Poly Haven's official asset API and `dl.polyhaven.org`. All six source assets are released under [CC0](https://polyhaven.com/license); attribution is not required. The project retains it for reproducibility.

Only the 1K JPG diffuse, OpenGL normal, and roughness maps were selected. No archive, executable, add-on, displacement map, account, purchase, or live runtime dependency is involved. Every file decoded as a `1024x1024`, 8-bit JPEG and its downloaded MD5 matched the value in the official API record.

| Runtime use | Poly Haven asset | Official page |
|---|---|---|
| vehicle asphalt | `clean_asphalt` | <https://polyhaven.com/a/clean_asphalt> |
| pedestrian paths | `concrete_pavement` | <https://polyhaven.com/a/concrete_pavement> |
| parking and paved areas | `concrete_floor_03` | <https://polyhaven.com/a/concrete_floor_03> |
| island ground | `sparse_grass` | <https://polyhaven.com/a/sparse_grass> |
| exterior building walls | `plaster_grey_04` | <https://polyhaven.com/a/plaster_grey_04> |
| flat building roofs | `bitumen` | <https://polyhaven.com/a/bitumen> |

## File inventory

Every source URL follows `https://dl.polyhaven.org/file/ph-assets/Textures/jpg/1k/<asset>/<file>`.

| File | Bytes | Official MD5 | Local SHA-256 |
|---|---:|---|---|
| `clean_asphalt/clean_asphalt_diff_1k.jpg` | 697630 | `7edccb95cbf72e63889baade8455f9e5` | `ddf9224e9cfa3eb2998d9097e4cd34bd3630c85e0e6798e5a0a000415a684083` |
| `clean_asphalt/clean_asphalt_nor_gl_1k.jpg` | 776360 | `24dadd366637a722b59c19a672cbbcf6` | `99cdf6b6f0b8a319d206e1d561bf2a5d9933d8d33e1d685f8e25388101d21310` |
| `clean_asphalt/clean_asphalt_rough_1k.jpg` | 641634 | `4238f2eab76530f4b0c66ddb929b142d` | `2280be133c104eb04370b625ebcc7f6709d2173b43ae2cd15a0074c26f492bf9` |
| `concrete_pavement/concrete_pavement_diff_1k.jpg` | 926197 | `b7a0d071a3406d55a1c3e9a73a06df03` | `70d3ff969a7421c7ae057b5d16386d11f5e59c6740db643352e1039413f419c4` |
| `concrete_pavement/concrete_pavement_nor_gl_1k.jpg` | 1184345 | `025a1d4e910cf3e5b3d63ada43a791d8` | `a5009e409ff0f7b2d19e1316fe5e2b2b4f28e4a6b79990a664be69d4e8a0e690` |
| `concrete_pavement/concrete_pavement_rough_1k.jpg` | 475799 | `e5a0fc9831bad12c7b3779179aa706f7` | `99f81099af07b009134b6a81bf0f95ab16da09c57156cc2ed534975664a68533` |
| `concrete_floor_03/concrete_floor_03_diff_1k.jpg` | 1184196 | `fcc1639eecf3b25e5e3ce6e4062d783e` | `6403524d194100d80e3040435b953ddf44e90069bd404cfb116204dec3c35df7` |
| `concrete_floor_03/concrete_floor_03_nor_gl_1k.jpg` | 1105067 | `fbe941aa20542e754384f7639fd170ed` | `f9f18d02c1e4e655aa321ddeaf2c696a87a9c4782fea7119c65310c510367f5a` |
| `concrete_floor_03/concrete_floor_03_rough_1k.jpg` | 914332 | `8d88d42011d662bdbbf61ab5def11132` | `13bf9548e801ada85c2445782544ad6ffba17c9ec08e39aa35c6f6ad2bc83961` |
| `sparse_grass/sparse_grass_diff_1k.jpg` | 955945 | `5d0aba796e1b5882555161c16b10ee9d` | `ae94f2b34597b9108eefd88217f55eccaec6d6b382e858a478ee92df90e66617` |
| `sparse_grass/sparse_grass_nor_gl_1k.jpg` | 1440314 | `3307e6ce47413c6b4e85885d4b8ae932` | `1c840a24807346ddaaf94a5057aee4078fcec3a4cd84bfe45da7d3b480ef460b` |
| `sparse_grass/sparse_grass_rough_1k.jpg` | 463340 | `acf2fd7e352e7635f67f24ecda01e485` | `9ebe6d03a9551c17d1802835c92c1442acb8f5d38d4874ee8c37770f11c4bed1` |
| `plaster_grey_04/plaster_grey_04_diff_1k.jpg` | 456938 | `bc8a1530a637d36865f90c86391c75c4` | `e78df7d6e762fe767634278e14316564e0d4510031986239458994ec9fc5410d` |
| `plaster_grey_04/plaster_grey_04_nor_gl_1k.jpg` | 983244 | `d1ada132c3eea7bee3abe7624c592391` | `9d0eb5299f797c07eb841737eb7164755a2c8a2363540e175a76188a2aa5a2dc` |
| `plaster_grey_04/plaster_grey_04_rough_1k.jpg` | 370366 | `ef0f4120c0b1085db4f6a08f7a0b197d` | `0d8cc6216ac3dc9dc4339cb17a08d249f7341961f432ae1451c35cdff222869b` |
| `bitumen/bitumen_diff_1k.jpg` | 451335 | `1a906cd5bcba943454d6f01065e0b1d9` | `fa09ed33d59c3bb90ef70d36352207e2e1ca5564cfc61295c0124d1a7d785808` |
| `bitumen/bitumen_nor_gl_1k.jpg` | 691370 | `937558b6fc9f423677762b3bdb52e7d6` | `a584bd64cac6ce37153b48a481612bc20be5d5f1d36cac572119560f67c1c756` |
| `bitumen/bitumen_rough_1k.jpg` | 272094 | `ead8140f094ac8a0fb573f0c11142593` | `ae78d0e22b3c771d8ae8fd392c721daf545bbc24f137aad978ddd899dd376b39` |

Total selected image payload: `13,990,506` bytes (`13.34 MiB`).
