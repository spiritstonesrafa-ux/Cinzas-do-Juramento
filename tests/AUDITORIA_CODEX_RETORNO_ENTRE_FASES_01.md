# RETORNO-ENTRE-FASES-01 — auditoria de retomada

Data: 11/11/2026. Branch `main`, HEAD `fe35d78801923c548028af2b479d37273bb0f6eb`. Trabalho local anterior preservado; índice vazio. Este documento não homologa o marco.

| Componente | Estado observado | Evidência e ação pendente |
| --- | --- | --- |
| Cemitério → Abadia | Gatilho e marca de origem implementados | `forgotten_cemetery.gd` e `encounter.gd`; verificar fluxo real sem manipulação direta. |
| Abadia → Cemitério | Gatilho de margem e chegada implementados | `chapter.gd` e `forgotten_cemetery.gd`; verificar passagem e respawn em campanha. |
| Abadia → Floresta | Gatilho condicionado à recompensa implementado | `chapter.gd`; verificar travessia física após cinematografia. |
| Floresta → Abadia | Gatilho e chegada no setor 11 implementados | `forest_demo.gd`, `chapter.gd`; verificar percurso com controles. |
| Spawns | Marcador `pending_entrance` transitório e coordenadas em código | Testes atuais atribuem posições e chamam `_physics_process` diretamente; não provam colisão, acessibilidade ou ausência de inimigo no ponto. |
| Chefes e habilidades | Flags e sincronização implementadas | Testes simulam flags com `_grant_fields`; vitória real e ausência de repetição durante percurso não foram comprovadas nesta auditoria. |
| Localização e checkpoint após reabertura | **Pendente** | `pending_entrance` é estático em memória; `tests/playtest_retorno_entre_fases.gd` instancia sempre `scenes/main.tscn`. Não foi identificada persistência do capítulo atual ou checkpoint para nova execução. Não confundir com persistência das recompensas. |
| Encontros | **Pendente** | `states` pertence ao controlador da cena; mudança de cena descarrega-o. Não foi comprovada preservação entre capítulos. |
| Respawn ao revisitar | **Parcial** | Há seleção de spawn de retorno e checkpoint local; testes dedicados de morte e reinício solicitados ainda são necessários. |

O relatório anterior `RELATORIO_RETORNO_ENTRE_FASES_01.md` é preservado como registro do Antigravity; suas afirmações abrangentes sobre cobertura e ausência de bloqueantes não são evidência de reabertura no capítulo/checkpoint ou de travessia contínua. A suíte verifica, por exemplo, ao menos um HUD (`hud_count >= 1`), condição insuficiente para demonstrar ausência de duplicação.

## Execuções desta auditoria

Godot 4.7.2, `--headless --path C:\PROJETOS\CINZAS DO JURAMENTO --script res://tests/<suíte>.gd`, com `APPDATA` e `SAVE_SAFETY_ISOLATED_ROOT` sob `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\retorno-auditoria-20261111`, perfil separado por suíte, sem usar save pessoal. Todos processos abaixo concluídos com código 0, sem falhas reportadas; não foi declarada contagem SKIP por todos os scripts.

| Suíte | PASS | FAIL |
| --- | ---: | ---: |
| retorno_entre_fases_01_test | 54 | 0 |
| integracao_sotn_campanha_01_test | 68 | 0 |
| contact_damage_01_test | 64 | 0 |
| ataque_sotn_03_test | 44 | 0 |
| ataque_sotn_02_art_fix02_test | 42 | 0 |
| ataque_sotn_01_test | 30 | 0 |
| save_safety_01_test | 44 | 0 |
| m6_cervo_boss_combat_test | 68 | 0 |
| m6_cervo_full_journey_test | 35 | 0 |
| boss1_transition_fix02_test | 23 | 0 |

Total 472 verificações relatadas pelas suítes. Os testes de SAVE-SAFETY geram intencionalmente avisos ao simular falhas; alguns testes reportaram avisos ObjectDB na saída. Os logs completos estão no diretório isolado acima. A suíte de retorno injeta flags, instancia cenas manualmente e chama métodos; seus 54 PASS não representam 54 testes físicos de campanha.

## Pendências antes da homologação

Implementar ou demonstrar de modo seguro a persistência de localização atual, fase mais avançada e checkpoint após reabertura, preservando compatibilidade e integridade dos saves existentes. Avaliar explicitamente semântica de encontros entre cenas. Criar teste de processo independente e teste físico de ida e volta, incluindo morte, spawns, progressão e condições extremas, sem utilizar save pessoal. Roteiro humano R1–R14 do pedido original permanece pendente; atalhos F6/F8 do launcher concedem flags e não são prova de percurso legítimo. O perfil `tests/perfil_playtest_retorno_fases/` já existe e contém progresso: não é novo e não deve ser limpo.

## Integridade

Antes da bateria: `project.godot` 3900 bytes SHA-256 `63FDDFB499D59CD3AE9B5B70D7D4A8816CCFD8586486C6CFCC3023733BCDCEC9`; save pessoal 267 bytes SHA-256 `13DE06DB1B10184A6256A5C4845C032D96B825791373FBD2EF739841E13DA0AB`. Os 15 protegidos foram conferidos com o baseline canônico disponível em `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\m5c3-20261104-01\baseline.json`. A tabela de `tests/VALIDACAO_M6_B3.md` contém uma divergência textual no hash apresentado para `fix03-after-sector3.png.import`; a comparação deve usar os valores completos do baseline e o arquivo real. Nenhum save pessoal foi usado em testes.

**Veredito: IMPLEMENTAÇÃO PARCIAL — PENDÊNCIAS IDENTIFICADAS.** Não foi alterado gameplay nesta auditoria, nem iniciado BOSS-BALANCE-01 ou Fase 4. Sem staging, commit, push ou deploy.
