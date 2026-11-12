# RETORNO-ENTRE-FASES-01 — PERSIST-FIX02

11/11/2026. Branch `main`, HEAD `fe35d78801923c548028af2b479d37273bb0f6eb`. Esta entrega permanece local e não está homologada.

## Implementação

A causa era o uso de `pending_entrance` exclusivamente em memória e a inicialização incondicional no Cemitério. `scripts/levels/campaign_bootstrap.gd`, associado à raiz de `scenes/main.tscn`, consulta a localização persistida na inicialização normal; uma chegada física explícita tem precedência. Saves legados sem localização iniciam no Cemitério, preservando suas recompensas. Os controladores existentes persistem a localização na chegada e quando um checkpoint seguro é ativado. A retomada usa o identificador de checkpoint correspondente à fase, ou uma entrada física conhecida; HP extra, dash e salto espectral continuam derivados das recompensas existentes. O maior capítulo é derivado das flags, sem regredir na volta.

`scripts/abbey/abbey_progress.gd` mantém a gravação existente com trava, revisão, checksum e backups e adiciona localização e estados dos setores. Abadia e Floresta serializam snapshots dos mecanismos existentes; a Abadia registra também atalhos, progresso e descobertas por índice. A política de respawn existente continua a limpar/resetar encontros quando já o fazia. Não se adicionou permanência indiscriminada aos inimigos do Cemitério. As passagens e coordenadas preexistentes foram reutilizadas.

## Testes

Todos os comandos usaram Godot 4.7.2 com `--headless --path <projeto> --script res://tests/<script>` e `APPDATA` e `SAVE_SAFETY_ISOLATED_ROOT` em perfis novos sob `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\persist02-*`. Logs ficam nesses perfis; nenhum usa save pessoal.

| Teste | Resultado efetivo |
| --- | --- |
| `retorno_fisico_fix02_test.gd` | 4 passagens PASS, código 0. Usa controles e física reais, começando perto das portas; prepara artificialmente a entrada oeste da Abadia. Não prova percurso completo dos mapas. |
| `retorno_persist_fix02_test.gd` | Dois processos PASS, códigos 0: entrada real na Abadia, checkpoint ativado por chamada de teste, reabertura pela cena principal, checkpoint seguro, respawn por chamada de teste, HP/dash, estado de um encontro e flags de atalhos. |
| `retorno_persist_forest_test.gd` | Dois processos PASS, códigos 0: retomada pela cena principal, checkpoint seguro, respawn por chamada de teste, HP/dash/salto. |
| `retorno_persist_cemetery_test.gd` | Dois processos PASS, códigos 0: retorno, checkpoint e retomada no Cemitério com habilidades e progresso máximo preservados. |
| `retorno_persist_fix01_test.gd` | Dois processos PASS, códigos 0: gravação e leitura dos metadados e progresso máximo em perfil isolado. |
| Repetição dos três testes de retomada com morte | Seis processos PASS: após reabrir cada fase, dano letal real, temporizador de morte e respawn no checkpoint restaurado; habilidades preservadas. A preparação do checkpoint continua sendo por chamada de teste. |
| `retorno_entre_fases_01_test.gd` | 54 PASS / 0 FAIL, código 0; usa preparação e chamadas diretas. |
| `save_safety_01_test.gd` | 44 PASS / 0 FAIL, código 0. |
| `ataque_sotn_01_test.gd` | 30 PASS / 0 FAIL, código 0. |
| `ataque_sotn_02_art_fix02_test.gd` | 42 PASS / 0 FAIL, código 0. |
| `ataque_sotn_03_test.gd` | 44 PASS / 0 FAIL, código 0. |
| `contact_damage_01_test.gd` | 64 PASS / 0 FAIL, código 0. |
| `integracao_sotn_campanha_01_test.gd` | 68 PASS / 0 FAIL, código 0. |
| `boss1_transition_fix02_test.gd` | 23 PASS / 0 FAIL, código 0. |
| `boss2_playtest_test.gd` | 46 PASS / 0 FAIL, código 0. |
| `m6_cervo_boss_combat_test.gd` | 68 PASS / 0 FAIL, código 0. |
| `m6_cervo_full_journey_test.gd` | 35 PASS / 0 FAIL, código 0. |
| `abbot_cinematic_test.gd` | CANCELADO após não terminar; até a interrupção havia PASS para retorno após vitória. O ensaio espera reentrar na arena enquanto o fluxo atual permite avanço à Floresta; não é prova de falha ou de aprovação da suíte inteira. |

Os scripts não reportam uniformemente SKIP; não se atribui contagem de SKIP não observada. A execução anterior com encerramento imediato produziu erros de carregamento de recursos assíncronos; ao aguardar o término dos carregamentos, as execuções finais em dois processos não os repetiram. O ambiente continua emitindo erro conhecido de leitura da cadeia de certificados do Windows.

## ObjectDB e limites

O teste anterior com `--verbose` reportou seis `RefCounted`, cinco com contagem zero e um com contagem um. Nas execuções finais houve avisos variáveis de 3 a 5 instâncias em algumas suítes. Não foi identificada a origem exata, nem comprovada ausência de acúmulo em múltiplas transições de longa duração; não se atribui automaticamente a uma fixture.

Resta validar jornada física completa encadeada, semântica de todos os encontros e a suíte cinematográfica cancelada. A ativação inicial dos checkpoints nos testes foi feita por chamada; a morte posterior usou dano e temporizador reais. A persistência do setor atual ocorre ao ativar checkpoint ou ao descarregar a cena; encerramento abrupto antes desses pontos pode perder mudanças recentes. Não se apresenta o marco como homologado ou tecnicamente completo enquanto estes itens não forem demonstrados.

## Preservação

Save pessoal e `project.godot` mantidos com hashes históricos; 15 protegidos comparados com o baseline independente sem divergências. A discrepância textual histórica da tabela M6-B3 para `fix03-after-sector3.png.import` não foi alterada. Índice Git vazio; sem commit, push ou deploy. Não iniciado BOSS-BALANCE-01 ou Fase 4.

**IMPLEMENTAÇÃO PARCIAL — VALIDAÇÃO RESTANTE.**
