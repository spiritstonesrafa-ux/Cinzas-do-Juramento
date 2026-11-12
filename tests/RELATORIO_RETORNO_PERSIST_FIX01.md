# RETORNO-ENTRE-FASES-01 / PERSIST-FIX01 — continuidade parcial

11/11/2026. Branch `main`, HEAD `fe35d78801923c548028af2b479d37273bb0f6eb`; índice vazio. Preservados os gatilhos, spawns e alterações anteriores do Antigravity. O relatório de auditoria anterior está em `tests/AUDITORIA_CODEX_RETORNO_ENTRE_FASES_01.md`.

## Diagnóstico e alteração

A entrada entre cenas usa `pending_entrance` estático, volátil. O launcher de retorno instancia sempre `scenes/main.tscn`; o capítulo e checkpoint de uma sessão não eram persistidos. As quatro direções possuem implementação prévia; sua travessia física contínua e segurança dos pontos de chegada ainda não foram demonstradas.

Em `scripts/abbey/abbey_progress.gd` foram acrescentadas `campaign_location()` e `save_campaign_location()`, que reutilizam `_grant_fields()` e sua trava, revisões e backups. Acrescentam opcionalmente `current_chapter` e `campaign_checkpoint`; o maior capítulo desbloqueado é derivado das recompensas persistidas, não reduzido ao revisitar uma fase. Save legado sem esses campos usa Cemitério como fallback; dados inválidos para capítulo também usam fallback. Escrita de capítulo além do máximo derivado é recusada. O campo de checkpoint ainda é apenas identificador textual: não há validação de posição ou ligação a um checkpoint real.

**Essas funções não estão conectadas aos controladores, transições ou launchers.** Portanto a campanha ainda não salva/restaura localização, checkpoint ou encontros. Não interpretar a API parcial como funcionalidade concluída. Falta ainda projetar e implementar a integração do fluxo oficial, política segura de checkpoint, estado de encontros e testes de travessia e respawn. Não foi declarada homologação.

## Testes novos realmente executados

Godot 4.7.2 headless, perfis novos em `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\persist-fix01-*`, APPDATA e SAVE_SAFETY_ISOLATED_ROOT apontando para o perfil isolado. Certificados do Windows produziram o diagnóstico conhecido da engine.

| Teste | Resultado |
| --- | --- |
| `tests/retorno_persist_fix01_test.gd`, processo `RETORNO_PERSIST_STAGE=write` | PASS, código 0: fallback em perfil novo, recompensas simuladas e gravação de capítulo/checkpoint. |
| Mesmo script, novo processo `RETORNO_PERSIST_STAGE=read` | PASS, código 0: leitura dos metadados e habilidades, gravação de retorno ao Cemitério sem reduzir máximo. Isto testa dados, **não** abertura real de cena/checkpoint. |
| `tests/save_safety_01_test.gd` | 44 PASS, 0 FAIL, código 0; avisos de falhas simuladas esperados. |
| `tests/retorno_entre_fases_01_test.gd` | 54 PASS, 0 FAIL, código 0; verifica cenas com reposicionamento e chamadas diretas. |
| Mesma suíte com `--verbose` | 54 PASS, código 0; seis instâncias `RefCounted` reportadas pelo ObjectDB, cinco com referência 0 e uma com referência 1. Origem exata e risco de acúmulo em campanha não determinados. |

As demais regressões requeridas, retorno físico, chefes reais, checkpoint/morte e abertura de campanha em segundo processo estão **NÃO EXECUTADOS** nesta rodada. Os 472 PASS da rodada anterior são histórico, não validação da alteração atual. Nenhum teste foi cancelado.

## Segurança e pendências

Save pessoal e `project.godot` comparados antes e depois; os 15 protegidos comparados com o baseline canônico da auditoria anterior. A tabela de `tests/VALIDACAO_M6_B3.md` apresenta divergência textual na entrada `fix03-after-sector3.png.import`; o arquivo corresponde ao baseline independente e não foi alterado. Não editar o manifesto.

O launcher `tests/playtest_retorno_entre_fases.gd` e o perfil persistente `tests/perfil_playtest_retorno_fases/` já existem; o perfil já contém progresso. O launcher ainda inicia no Cemitério e seus atalhos de teste concedem flags. Não apresentar essa execução como prova de retomada. A validação humana R1–R14 permanece pendente.

**IMPLEMENTAÇÃO PARCIAL — PENDÊNCIAS IDENTIFICADAS.** Sem staging, commit, push ou deploy; não foram iniciados balanceamento ou Fase 4.
