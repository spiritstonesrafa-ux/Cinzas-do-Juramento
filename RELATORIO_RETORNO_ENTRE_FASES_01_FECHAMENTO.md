# RETORNO-ENTRE-FASES-01 — relatório de fechamento técnico

Data: 11/11/2026. Branch `main`; HEAD `fe35d78801923c548028af2b479d37273bb0f6eb`; índice vazio. Foram preservadas as alterações anteriores do Antigravity e do PERSIST-FIX02. O status inicial expandido tinha 1494 caminhos; o atual inclui também os novos documentos e testes deste fechamento. Não houve staging, commit, push ou deploy.

## Trabalho e pontos de entrada

Os controles existentes e as passagens físicas continuam sendo usados. A persistência de capítulo/checkpoint e os snapshots estão descritos em `tests/RELATORIO_RETORNO_PERSIST_FIX02.md`. Neste fechamento, `scripts/abbey/chapter.gd` foi corrigido para gravar os estados já capturados ao sair diretamente da arena do Abade. `tests/abbot_cinematic_test.gd` teve a preparação da revisita corrigida: depois de derrotado, caminhar à direita leva legitimamente à Floresta; a fixture instancia explicitamente a arena para conservar os asserts sobre seu estado derrotado e a ausência de repetição da cinematografia. Essa preparação não é prova de uma passagem física para revisitar a arena.

Os demais arquivos do marco incluem `scenes/main.tscn`, `scripts/levels/campaign_bootstrap.gd`, `scripts/levels/forgotten_cemetery.gd`, `scripts/abbey/abbey_progress.gd`, `scripts/forest/forest_demo.gd`, `tests/retorno_entre_fases_01_test.gd`, `tests/retorno_persist_fix01_test.gd`, `tests/retorno_persist_fix02_test.gd`, `tests/retorno_persist_cemetery_test.gd`, `tests/retorno_persist_forest_test.gd` e `tests/retorno_fisico_fix02_test.gd`. Foi criado `tests/retorno_persist_bridge_test.gd` para o cenário de retorno e reabertura.

## Travessias e retomada

`retorno_fisico_fix02_test.gd` usou movimento e física e concluiu as quatro passagens nos dois sentidos, a partir de posições próximas às portas. O teste prepara artificialmente a entrada oeste da Abadia entre as duas conexões. Não demonstra caminhada contínua através de todos os setores ou combate da jornada completa.

`retorno_persist_bridge_test.gd`, em dois processos independentes, preparou recompensas em perfil isolado, atravessou Floresta → Abadia com movimento real, ativou o checkpoint 7 por chamada de fixture, fechou e reabriu através da cena principal. Confirmou Abadia, checkpoint, HP 6, dash e maior capítulo Floresta. Os testes `retorno_persist_cemetery_test.gd`, `retorno_persist_fix02_test.gd` e `retorno_persist_forest_test.gd` repetiram, em dois processos por fase, retomada, habilidades e morte com respawn após ativação de checkpoint pela fixture. `retorno_persist_fix01_test.gd` repetiu gravação/leitura e preservação do progresso máximo. Todos esses processos terminaram com código 0.

## Matriz de encontros e limites

| Fase/categoria | Regra observada no código | Evidência desta rodada | Limite |
| --- | --- | --- | --- |
| Cemitério, inimigos comuns | Cena nova e `_restore_enemies()` restauram inimigos; não se adicionou derrota permanente. | Código e suíte de integração. | Não foi realizado inventário individual de todos os inimigos em viagens e reinício. |
| Guardião | Vitória/recompensa no save; encontro concluído não é obrigatório novamente. | `boss1_transition_fix02_test.gd` 23/23; testes de retorno. | Jornada completa com vitória humana não repetida nesta rodada. |
| Abadia, encontros de setor | `snapshot()` de piloto e saúde de distribuição, restaurados por setor; morte usa a política existente de reset. | Fixture de retomada em dois processos comprova um inimigo do setor 1, checkpoint e flags de atalhos. | Não foram testados individualmente todos os encontros, riscos, segredos e atalhos. |
| Abade | Derrota/dash persistem; saída concluída vai para a Floresta. | `boss2_playtest_test.gd` 46/46 e cinematografia 26/26. | Revisita da arena na suíte cinematográfica é fixture direta. |
| Floresta, inimigos e perigos | Snapshot por IDs de encontro guarda vida/estado/posição e estado dos perigos; morte executa reset existente. | Código e suítes de jornada e combate; retomada de checkpoint testada. | Sem teste individual de cada inimigo/perigo entre capítulos e reinício. |
| Cervo | Flags de vitória e salto espectral persistem. | Combate 68/68, jornada 35/35 e retomada da Floresta em dois processos. | Derrota legítima e volta pelo mapa inteiro não foram repetidas continuamente nesta rodada. |

## Suítes executadas

Godot `4.7.2` executado com `--headless --path C:\PROJETOS\CINZAS DO JURAMENTO --script res://tests/<nome>.gd`. APPDATA e SAVE_SAFETY_ISOLATED_ROOT apontaram para perfis novos sob `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\fechamento-*`; logs permanecem nesses diretórios. Códigos abaixo são 0 para as execuções concluídas; contagem de SKIP não é reportada de modo uniforme pelas suítes.

| Suíte | Resultado |
| --- | --- |
| `retorno_fisico_fix02_test.gd` | 4 passagens PASS, código 0. |
| `retorno_entre_fases_01_test.gd` | 54 PASS, 0 FAIL, código 0. |
| `save_safety_01_test.gd` | 44 PASS, 0 FAIL, código 0. |
| `ataque_sotn_01_test.gd` | 30 PASS, 0 FAIL, código 0. |
| `ataque_sotn_02_art_fix02_test.gd` | 42 PASS, 0 FAIL, código 0. |
| `ataque_sotn_03_test.gd` | 44 PASS, 0 FAIL, código 0. |
| `contact_damage_01_test.gd` | 64 PASS, 0 FAIL, código 0. |
| `integracao_sotn_campanha_01_test.gd` | 68 PASS, 0 FAIL, código 0. |
| `boss1_transition_fix02_test.gd` | 23 PASS, 0 FAIL, código 0. |
| `boss2_playtest_test.gd` | 46 PASS, 0 FAIL, código 0. |
| `m6_cervo_boss_combat_test.gd` | 68 PASS, 0 FAIL, código 0. |
| `m6_cervo_full_journey_test.gd` | 35 PASS, 0 FAIL, código 0. |
| `abbot_cinematic_test.gd` | 26 PASS, 0 FAIL, código 0, com fixture de revisita explícita. |
| `retorno_persist_fix01_test.gd` e três suítes por fase | Oito processos write/read PASS, códigos 0. |
| `retorno_persist_bridge_test.gd` | Dois processos write/read PASS, códigos 0. |

O cancelamento histórico da suíte do Abade continua documentado no relatório anterior e não foi contado como PASS. O log tinha parado após `Point 14: Hero retains dash in Sector 12`; a fixture esperava `arena_active` ao caminhar na saída que agora vai à Floresta. Após mudar somente a preparação da revisita, a suíte concluiu. O ambiente registra o aviso conhecido de certificados do Windows.

## ObjectDB

Duas execuções independentes com `--verbose` do teste das quatro passagens reportaram três instâncias `RefCounted` cada, todas com contagem de referência 0. A suíte cinematográfica reportou quatro na saída. Isso não mostra aumento entre processos idênticos, mas também não prova ausência de acúmulo numa única sessão longa. A origem exata, relação com fixtures e impacto ainda não foram determinados.

## Integridade

Save pessoal: 267 bytes, SHA-256 `13DE06DB1B10184A6256A5C4845C032D96B825791373FBD2EF739841E13DA0AB`. `project.godot`: 3900 bytes, SHA-256 `63FDDFB499D59CD3AE9B5B70D7D4A8816CCFD8586486C6CFCC3023733BCDCEC9`. Os 15 protegidos conferem com o baseline independente `m5c3-20261104-01/baseline.json`. A divergência textual histórica da tabela em `tests/VALIDACAO_M6_B3.md` para `fix03-after-sector3.png.import` permanece sem alteração. Nenhum save pessoal foi usado nos testes.

## Preparação do playtest — não homologar automaticamente

O launcher existente é `tests/playtest_retorno_entre_fases.gd`. A linha abaixo usa uma pasta nova e persistente; F6/F8 do launcher concedem flags e não devem ser usados para comprovar progressão legítima:

```powershell
$oldA=$env:APPDATA;$oldS=$env:SAVE_SAFETY_ISOLATED_ROOT;try{$p='C:\PROJETOS\CINZAS DO JURAMENTO\tests\perfil_playtest_retorno_final';if(-not(Test-Path -LiteralPath $p)){New-Item -ItemType Directory -Path $p|Out-Null};$env:APPDATA=$p;$env:SAVE_SAFETY_ISOLATED_ROOT=$p;& 'C:\Users\ovohe\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' --path 'C:\PROJETOS\CINZAS DO JURAMENTO' --script res://tests/playtest_retorno_entre_fases.gd}finally{$env:APPDATA=$oldA;$env:SAVE_SAFETY_ISOLATED_ROOT=$oldS}
```

Roteiro: R1 Cemitério → Abadia; R2 voltar ao Cemitério; R3 confirmar Guardião derrotado; R4 reentrar na Abadia; R5 seguir à Floresta após Abade; R6 voltar à Abadia; R7 seguir ao Cemitério; R8 retornar pela Abadia à Floresta; R9 verificar HP, dash e SOTN; R10 após Cervo verificar salto espectral no retorno; R11 morrer e conferir respawn em fase revisitada; R12 fechar/reabrir e conferir fase/checkpoint; R13 conferir encontros conforme a matriz; R14 verificar loops, spawns e travamentos. A pasta de perfil não deve ser apagada entre sessões.

## Veredito

**IMPLEMENTAÇÃO PARCIAL — VALIDAÇÃO TÉCNICA RESTANTE.** A cinematografia interrompida foi resolvida e as passagens locais e retomadas descritas passaram. A jornada contínua completa permanece para playtest e a persistência de todos os encontros ainda não foi comprovada individualmente; a origem dos avisos ObjectDB continua em aberto. Não há justificativa para apresentar esses itens como PASS ou declarar homologação humana.

## Complemento de auditoria — 11/11/2026

Em nova rodada foi criado `tests/retorno_encontros_final_test.gd`. Em perfis isolados, as fixtures prepararam estados derrotados, navegaram pelos setores através dos controladores, salvaram, carregaram outra fase e retornaram; um segundo processo leu o mesmo perfil e verificou os estados carregados. Os 20 inimigos da distribuição da Abadia, mais o monge da Galeria, passaram na revisita e na reabertura. Na Floresta, 24 inimigos dos setores 1–9 passaram na revisita e reabertura. A preparação da derrota e a seleção de setores foram artificiais: isto demonstra persistência de estado, não combate ou travessia contínua. A semântica dos perigos temporizados e os eventos do setor do chefe ainda não foram exaustivamente exercitados por essa matriz. O Cemitério continua com respawn normal de inimigos comuns conforme seu controlador; chefes usam flags próprias.

Os quatro processos da matriz retornaram código 0; logs em `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\retorno-matriz-galeria-20261111`. A bateria foi novamente executada nesta rodada, com perfis e logs em `...\retorno-final-20261111`: quatro passagens físicas, retorno 54/54, SAVE-SAFETY 44/44, SOTN 30/30, ART-FIX02 42/42, SOTN-03 44/44, contato 64/64, integração 68/68, Guardião 23/23, Abade 46/46, cinematografia 26/26, combate Cervo 68/68 e jornada Cervo 35/35; todos com código 0. Não foram observados FAIL nas respectivas saídas; SKIP não é informado uniformemente.

O roteiro humano R1–R14 e o comando isolado acima continuam válidos. A sequência integral de setores não foi automatizada; não se declara que um bot percorreu toda a campanha. A existência de um caminho completo deve ser examinada no playtest, assim como o comportamento dos perigos e eventos não cobertos pela matriz. Os três avisos `RefCounted` permanecem sem identificação de script ou medição conclusiva de acúmulo em sessão longa.

## Resultado final da rodada

A matriz foi ampliada para verificar os quatro perigos temporizados da Floresta: valores de tempo preparados pela fixture foram recuperados após saída e retorno entre capítulos e novamente em outro processo. Os 20 inimigos da distribuição da Abadia, o monge da Galeria e os 24 inimigos da Floresta passaram novamente nas mesmas condições. Quatro processos concluíram com código 0; logs em `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\retorno-matriz-perigos-20261111`. A fixture seleciona setores e prepara estados diretamente; o teste não é uma campanha jogada, nem prova todos os estados temporais de cada perigo.

As cinco suítes de retomada foram repetidas nesta rodada em dez processos independentes, todos com código 0, em `...\retorno-retomada-final-20261111`: FIX01, Cemitério, Abadia, Floresta e retorno físico Floresta → Abadia seguido de reabertura. Os ensaios de cada fase incluem morte real após a reabertura. A execução completa e contínua dos setores continua reservada ao roteiro humano R1–R14; as quatro portas foram verificadas com movimento e física sem chamadas diretas de transição durante a travessia local.

**RETORNO-ENTRE-FASES-01 — IMPLEMENTAÇÃO TÉCNICA CONCLUÍDA, AGUARDANDO HOMOLOGAÇÃO HUMANA**, com as seguintes limitações expressas: a jornada completa não foi automatizada; testes de estados usam fixtures; a origem dos avisos `RefCounted` não foi identificada e não há prova de ausência de acúmulo em sessão longa. Estas limitações não constituem aprovação do playtest ou prova de ausência de vazamento. O veredito parcial acima é histórico, anterior à ampliação da matriz.
