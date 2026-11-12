# Correção de lentidão — Coro, checkpoints e Cervo

11/11/2026. Relato do responsável: lentidão no Coro da Abadia, pausas nos checkpoints da Floresta e travamento severo na entrada do Cervo. Não se afirma homologação visual ou de desempenho pelo responsável após esta correção.

## Causa observada

`AbbeyProgress.read_progress()` verifica o arquivo principal e todos os backups válidos, inclusive checksums, e preserva a detecção de conflitos e a recuperação. O Coro consultava `unlocked()` a cada atualização de física perto da saída; o setor do Cervo consultava `is_flag_set()` e, quando necessário, `spectral_jump_unlocked()` a cada atualização. O perfil isolado anterior de playtest continha 52 backups. Assim, o custo de disco e verificação se repetia em cada quadro e crescia com o histórico de backups.

Um checkpoint da Abadia ou Floresta realizava duas transações síncronas, cada qual verificando o histórico e escrevendo sua própria revisão. Além disso, `_grant_fields()` e `_save_locked()` faziam duas varreduras consecutivas mesmo sob a mesma trava.

## Correção

- `scripts/abbey/chapter.gd`: lê a vitória do Abade uma vez ao entrar e atualiza a variável quando a recompensa é concedida; a física não varre backups continuamente.
- `scripts/forest/forest_demo.gd`: lê a vitória do Cervo ao entrar; a narrativa passa a observar o desbloqueio em memória de Aren durante a batalha, sem ler o disco a cada quadro.
- `scripts/abbey/abbey_progress.gd`: o checkpoint registra estado do capítulo, localização e checkpoint em **uma única transação**. A verificação de desbloqueio ocorre sob a trava; o histórico válido é reutilizado dentro da mesma transação, sem remover validações, backups ou regras de recuperação. `chapter.gd` e `forest_demo.gd` avisam se a gravação falhar.
- Nenhum backup ou save foi removido, incluindo o perfil de playtest e o save pessoal. Não houve alteração de movimento, IA, dano, combate ou arte.

## Medições

Godot 4.7.2, headless, perfil isolado com 100 backups artificiais adicionais, sem usar dados pessoais. `tests/retorno_performance_save_test.gd` mediu dez chamadas consecutivas aos controladores reais, com Aren no Coro ou no setor do Cervo. É medição localizada de CPU/disco, **não** benchmark gráfico 4K nem FPS de uma partida completa.

| Medida | Antes | Depois |
| --- | ---: | ---: |
| 10 atualizações no Coro | 1.029,920 ms | 1,677 ms |
| 10 atualizações no setor do Cervo | 2.252,646 ms | 0,108 ms |
| Checkpoint com cerca de 100 backups, duas transações antigas vs. uma nova | 350,236 ms | 113,998 ms |

As medições de checkpoint foram feitas na mesma implementação corrigida comparando o antigo encadeamento de duas operações públicas com a nova operação única; os dados da fixture diferem. A gravação continua síncrona e ainda pode provocar pausa perceptível com muitos backups ou armazenamento lento. Nenhuma medição prova que a pausa desapareceu no computador do responsável; não se recomenda apagar backups para compensar o custo.

## Verificação

Testes Godot com perfis `APPDATA` e `SAVE_SAFETY_ISOLATED_ROOT` isolados: `save_safety_01_test.gd` 44/44; `retorno_entre_fases_01_test.gd` 54/54; `retorno_fisico_fix02_test.gd` quatro passagens; `integracao_sotn_campanha_01_test.gd` 68/68; `contact_damage_01_test.gd` 64/64; `boss2_playtest_test.gd` 46/46; `abbot_cinematic_test.gd` 26/26; `m6_cervo_boss_combat_test.gd` 68/68; `m6_cervo_full_journey_test.gd` 35/35. Todos concluíram com código 0. O novo `retorno_checkpoint_safety_test.gd` confirmou, com código 0, uma revisão por checkpoint, preservação das recompensas, recusa de fase bloqueada e recusa sob trava concorrente. As cinco suítes de retomada foram repetidas em dez processos, todos código 0.

Os logs estão sob `C:\Users\ovohe\.codex\visualizations\2026\11\03\01a19f0a-ee96-7412-bd99-7c6152fadd40\perf-*`. Persistem diagnósticos ambientais de certificados e avisos históricos ObjectDB em algumas saídas. A segurança do save e os 15 arquivos protegidos devem ser conferidos novamente após os testes.

## Playtest necessário

No mesmo perfil isolado de campanha já utilizado pelo responsável, caminhar até o fim do Coro, acionar checkpoints em setores diferentes da Floresta e entrar/lutar com o Cervo. Observar movimento contínuo, duração da pausa no checkpoint, qualidade gráfica e resposta dos controles; verificar que recompensas, progresso e retorno entre fases continuam corretos. Não usar perfil pessoal para experimentos destrutivos ou apagar arquivos de progresso.

## Complemento — pausa residual do checkpoint

Após o responsável confirmar melhora na batalha e relatar uma pausa leve no checkpoint, a gravação foi transferida para uma `Thread` por controlador de capítulo. O snapshot é copiado antes de iniciar a tarefa; na saída da cena, a thread é aguardada antes de salvar o estado final. Se outra ativação ocorrer antes da conclusão, a gravação anterior é aguardada para preservar ordem. Se a thread não puder iniciar, a gravação síncrona é usada como fallback. O protocolo de trava, checksum, backups e escrita verificada permanece o mesmo.

No mesmo ensaio headless com cerca de 100 backups, a ativação real do checkpoint da Floresta levou **0,343 ms no quadro**, enquanto a gravação completa da fixture demorou aproximadamente 91 ms fora do quadro. A medição é localizada; não garante desempenho em todas as máquinas. Saída de fase imediata ou ativações muito próximas ainda podem aguardar a gravação pendente, e encerramento forçado do processo pode interromper uma gravação em andamento; a recuperação segue as regras do SAVE-SAFETY.

`checkpoint_async_test.gd` ativou o checkpoint e desalocou a fase imediatamente; confirmou a localização e recompensas preservadas após a espera de saída. O ensaio SAVE-SAFETY passou 44/44 e `retorno_checkpoint_safety_test.gd` passou as verificações de trava, fase bloqueada, recompensas e revisão única. Retorno 54/54, quatro passagens físicas, integração 68/68, contato 64/64, Abade 46/46, cinematografia 26/26 e Cervo 68/68 e jornada 35/35 concluíram com código 0. Oito processos write/read de retomada das três fases e da ponte Floresta → Abadia passaram. As fixtures que verificavam imediatamente o arquivo após a ativação agora aguardam explicitamente a conclusão da thread antes das mesmas verificações; duas primeiras execuções, antes dessa adaptação, falharam por consultar o arquivo ainda não gravado e não são contabilizadas como PASS.

Logs adicionais: `...\perf-async-after`, `...\perf-async-safety`, `...\perf-async-reg` e `...\perf-async-restart-final`. O save pessoal não foi usado. A melhora percebida pelo responsável ainda deve ser verificada em playtest.
