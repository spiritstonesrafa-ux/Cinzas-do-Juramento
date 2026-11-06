# M5-H — inventário inicial de inimigos

Baseline anterior à implementação: `main` em `2ac02cf0344b5fa5fc447b301cfdd8bae397be43`. Contam-se instâncias autoradas, sem bosses, armadilhas, respawns ou cenas demonstrativas.

## Fase 1 — Cemitério

Fonte: `scenes/levels/forgotten_cemetery.tscn`, nó `Enemies`. Total inicial: **6**.

| Região | Identificador | Tipo | Posição |
| --- | --- | --- | --- |
| Lápides | SkeletonPatrol | esqueleto | (744, 140) |
| Jardim | CursedRaven | corvo | (1050, 112) |
| Catacumbas | CryptSkeleton | esqueleto | (1328, 220) |
| Ponte | BridgeRaven | corvo | (1552, 112) |
| Catedral | CathedralSkeleton | esqueleto | (2120, 156) |
| Catedral | CathedralRaven | corvo | (2188, 112) |

## Fase 2 — Abadia

Fonte: `scripts/abbey/m5c3_distribution.gd`, posições locais de cada setor e índices de `AbbeyChapterLayout.main_surfaces`. Total inicial: **10**. As três armadilhas e outros perigos não são inimigos; as áreas opcionais não possuem inimigos autorados próprios identificados.

| Setor | Tipo | x | superfície |
| --- | --- | ---: | ---: |
| 2 Claustro | monge | 580 | 5 |
| 4 Dormitório | acólito | 550 | 5 |
| 5 Cisternas | acólito | 950 | 11 |
| 7 Fundição | vigia | 410 | 4 |
| 7 Fundição | monge | 1080 | 11 |
| 8 Ponte | penitente | 550 | 5 |
| 9 Arquivo | acólito | 510 | 5 |
| 10 Jardim | penitente | 450 | 4 |
| 11 Campanário | vigia | 420 | 5 |
| 12 Coro | monge | 525 | 4 |

Setores 1, 3 e 6: nenhum inimigo comum inicialmente. A arena do Abade é separada e não entra na contagem. Adições e verificações serão registradas após implementação; este inventário não comprova justiça ou percursos.

## Adições M5-H

O total finito passou de 6 para **12** no Cemitério e de 10 para **20** na Abadia: seis e dez adições respectivamente, **100% em cada fase**. A auditoria executável é `tests/m5_h_inventory_test.gd`.

| Cemitério — região | Novo identificador | Tipo | Posição |
| --- | --- | --- | --- |
| Portões | M5HGateSkeleton | esqueleto | (340, 156) |
| Lápides | M5HGraveSkeleton | esqueleto | (505, 144) |
| Lápides | M5HGraveRaven | corvo | (610, 112) |
| Jardim | M5HGardenSkeleton | esqueleto | (928, 140) |
| Catacumbas | M5HCryptRaven | corvo | (1450, 150) |
| Ponte | M5HBridgeRaven | corvo | (1745, 100) |

Por região, os totais inicial → final são **0→1, 1→3, 1→2, 1→2, 1→2, 2→2**. O fim da Catedral foi deixado sem novas instâncias para preservar a aproximação da arena. Os corvos introduzem alvos aéreos e os esqueletos ocupam superfícies existentes; os intervalos foram escolhidos para criar encontros distribuídos. A justiça dos encontros ainda depende de playtest.

| Abadia — setor | Adicionado | Posição local | Inicial → final |
| --- | --- | --- | --- |
| 1 Átrio | monge | (320, 284) | 0→1 |
| 2 Claustro | — | — | 1→1 |
| 3 Escadaria | monge | (600, 444) | 0→1 |
| 4 Dormitório | penitente | (900, 396) | 1→2 |
| 5 Cisternas | monge | (380, 372) | 1→2 |
| 6 Galeria | monge | (450, 300) | 0→1 |
| 7 Fundição | acólito | (850, 324) | 2→3 |
| 8 Ponte | monge | (260, 284) | 1→2 |
| 9 Arquivo | vigia | (1060, 252) | 1→2 |
| 10 Jardim | acólito | (680, 300) | 1→2 |
| 11 Campanário | monge | (1030, 324) | 1→2 |
| 12 Coro | — | — | 1→1 |

As adições usam as superfícies existentes e a instanciação por setor; os setores 2 e 12 não ganharam inimigos. Não foram acrescentados inimigos às áreas opcionais nem à arena do Abade. A distribuição combina inimigos já existentes, com concentrações maiores em setores longos; não foi provada justiça de cada combinação ou a segurança de todas as interações com caminhos opcionais.
