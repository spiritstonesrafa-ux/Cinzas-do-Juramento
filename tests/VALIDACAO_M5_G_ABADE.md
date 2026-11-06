# M5-G — Abade das Correntes e dash de Aren

**Veredito técnico: PARTIAL.** Arena, combate, duas fases, dash ofensivo e recompensa persistente foram implementados e há provas físicas e regressões descritas abaixo. Uma jornada contínua da entrada da Abadia até a vitória foi demonstrada em uma estratégia automatizada; ainda não se demonstrou a justiça de todas as aproximações e todos os padrões nem a interação do dash com todas as portas e rotas. A identidade visual usa composição provisória de recursos originais existentes e depende da avaliação do responsável. Não há homologação visual, de dificuldade ou funcional do M5-G inferida.

## Baseline e integração

Baseline: `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`, 147 entradas locais antes da implementação; alterações anteriores preservadas. M5-F homologado pelo responsável após informação “playtest ok”, com as ressalvas M5-C3, ObjectDB, pico isolado 183,878 ms e mínimo físico global não comprovado (critério revisto). Os 15 arquivos protegidos foram mantidos sem alteração; `project.godot` não foi modificado nesta etapa.

Após a saída normal à direita do S12, a Abadia carrega `scenes/abbey/abbot_arena.tscn`, mantendo os 12 setores e sete checkpoints anteriores. A arena é uma sala própria de 320 px de largura com chão e paredes sólidas, câmera fixa e fundo/atlas da Abadia; não altera a espinha histórica de 17.360,42 px. A derrota de Aren descarrega o encontro e retorna ao checkpoint válido; reentrada cria outro Abade. Após vitória e gravação bem-sucedida, E retorna ao Coro; ao chegar novamente ao fim da região com recompensa persistente, a saída informa fim estrutural, sem criar próxima região.

## Chefe e combate

`scripts/abbey/abbot.gd` contém estados introdução, perseguição, aviso, ataque ativo, recuperação, transição e derrotado. O Abade usa receptor de espada e fonte de dano dos contratos existentes: HP inicial 10, dano 1; recebe acerto uma vez por golpe conforme `SwordAttack`. A fase 1 alterna golpe de corrente e varredura e usa perseguição como pressão. A fase 2 começa ao atingir 5 HP, com transição de 1,0 s; introduz dash de 180 px/s por até 0,42 s após aviso de 1,15 s. Avisos normais duram 0,95 s, ataque normal 0,22 s, recuperação 1,25 s, perseguição 32 px/s. Os valores são parâmetros iniciais e devem ser ajustados conforme playtest, sem presumir aprovação humana.

O avanço usa `move_and_slide`, corpo com máscara para cenário e Aren, além de limites de arena. As hitboxes são ativadas apenas no estado ativo e desarmadas na recuperação, morte e derrota do jogador. O visual usa atlas original de Acólito, escalado e combinado com aro, sinais e rastro; é uma **solução provisória**, não um conjunto autoral novo de sprites específico. Movimento/animação é vinculado aos estados, mas a qualidade e distinção do Abade em relação aos inimigos comuns precisam de revisão. São três padrões implementados (corrente, varredura e dash) mais perseguição, não as seis famílias históricas propostas como possibilidades no plano.

## Vitória, dash e persistência

Na vitória, as fontes de dano são interrompidas. A concessão é confirmada após 0,8 s, somente se o jogador estiver vivo na mesma arena; derrota simultânea não concede recompensa no caso ensaiado. O jogador recebe a mensagem **“Técnica assimilada: Shift deslizar”** e pode retornar com E. Caso a gravação falhe, E oferece nova tentativa; não se declara a habilidade desbloqueada sem gravação bem-sucedida.

O deslizamento terrestre usa **Shift**, direção pressionada ou direção atual, velocidade 260 px/s, duração 0,16 s e cooldown 0,75 s. Usa `move_and_slide`, sem invulnerabilidade adicional e sem alterar o ataque aéreo. Antes da vitória válida, permanece bloqueado. Quando não usado, velocidade, gravidade e salto existentes permanecem os mesmos; testes M0/M1/M2 foram repetidos.

`scripts/abbey/abbey_progress.gd` grava um único arquivo `user://cinzas_abbey_progress_v1.json`, contendo versão e flags de vitória/dash, via arquivo novo temporário e renomeação. Arquivo ausente significa bloqueado; dados inválidos não desbloqueiam e não são sobrescritos. Se houver arquivo inválido, arquivo temporário pendente ou erro de escrita, a recompensa não é marcada como salva e o jogo informa falha; a recuperação automática de tais arquivos não foi implementada. Não há múltiplos perfis/slots. Os testes usaram perfis `APPDATA` isolados no ambiente de teste, sem alterar o progresso pessoal existente.

## Testes executados

Ambiente: Godot 4.7.2 Windows, candidata isolada extraída do HEAD e sobreposta com scripts e cenas locais, incluindo M5-E e M5-G. Comando geral `Godot_v4.7.2-stable_win64_console.exe --headless --path <cópia> --script res://tests/<teste>.gd`, com `APPDATA` de teste isolado; ensaios gráficos sem `--headless`. A candidata não é commit, e testes focados não garantem equivalência integral de um futuro checkout. Importação da cópia: código 0, com diagnósticos de certificado e escrita do perfil do editor registrados.

| Verificação | Resultado e limite |
|---|---|
| `m5_g_journey_test.gd` | Código 0: entrada no S1, travessia contínua dos 12 setores com entradas e ameaças reais e entrada na arena após S12. O ensaio para ao chegar; não executa o duelo no mesmo ciclo. |
| `m5_g_full_journey_test.gd` — primeira tentativa | Primeira tentativa código 1: trajeto desde S1 chegou à arena com 2 HP, mas o controlador morreu. Segunda tentativa código 0, em perfil novo e estratégia de espera/recuo: percurso contínuo, dash do Abade observado, vitória, recompensa salva e HP 2 ao fim, sem reposição artificial entre setores e luta. |
| `m5_g_abbot_test.gd` | Código 0: setor 12 preparado como fixture, entrada física na arena, luta por inputs e golpes reais, fase 2, dash do Abade, vitória, recompensa, retorno com E e liberação do fim estrutural. A luta usou HP normal e Aren sem dash antes da vitória. |
| `m5_g_dodge_test.gd` | Código 0: estado de fase 2 preparado como fixture, salto acionado 0,20 s antes do fim do aviso, dash físico observado, HP 5 mantido e fonte desligada na recuperação. Em tentativa anterior com 0,35 s o jogador sofreu dano; o caso aprovado não prova que qualquer tempo ou posição seja seguro. |
| `m5_g_conventional_test.gd` | Código 0: em fixtures isoladas, recuo evitou dano da corrente e da varredura e as fontes foram desarmadas na recuperação; uma direção e um posicionamento por padrão. |
| `m5_g_boss_collision_test.gd` | Código 0: em fixture de dash frente a Aren apoiado, o chefe não atravessou o corpo e encerrou a fonte na recuperação; o jogador recebeu dano no caso. |
| `m5_g_respawn_test.gd` | Código 0: CP7 ativado em fixture, morte, retorno ao S12, dash ainda bloqueado e reentrada com HP do Abade restaurado. |
| `m5_g_persistence_probe.gd` / `m5_g_session_test.gd` | Código 0: novo processo leu recompensa após vitória, Shift realizou dash, cooldown impediu repetição imediata, parede sólida bloqueou avanço e dano foi aceito durante dash; morte, queda induzida e F7 mantiveram habilidade. O primeiro ensaio de limite confundia uma transição normal de setor com atravessamento; foi substituído por uma parede física controlada. |
| `m5_g_locked_shortcut_test.gd` | Código 0: com dash salvo e nova sessão, Shift junto ao atalho A3 trancado não abriu a passagem nem registrou visita a S10; a posição inicial foi preparada em fixture. |
| `m5_g_dash_o1_test.gd` a `o6_test.gd` / `m5_g_dash_shortcuts_test.gd` | Todos código 0: dash efetivamente ativado no início de cada setor antes da prova física de O1–O6; os três corredores foram percorridos nos dois sentidos com dash ativado. Não se usou dash em cada salto ou porta de todas as rotas. |
| `m5_g_invalid_save_test.gd` | Código 0: JSON inválido não concede habilidade e não é sobrescrito. A engine emite diagnóstico de JSON inválido, sem crash no ensaio. |
| `m5_g_cancel_test.gd` | Código 0: HP do chefe preparado como fixture e derrota simultânea induzida não concederam recompensa. O teste de vitória real acima não depende dessa fixture. |
| M0 / M1 / M2 | M0 14 verificações; M1 36/36; M2 59/59, todos código 0. |
| Distribuição / atalhos / O1–O6 | Distribuição M5-C3 157/157; fixture dos três atalhos código 0; O1 e O2–O6 código 0 nas provas existentes. Os testes M5-G adicionais abaixo ativaram o dash antes de cada rota e nos corredores, sem cobrir todos os pontos possíveis. |
| `m5_g_performance_test.gd` | Gráfico, janela solicitada 3840×2160, 745 quadros de combate, 60,00 FPS médio, média 16,666 ms, p95 16,896 ms, máximo 18,563 ms; outras suítes estavam em execução. A medição ocorreu antes de uma proteção posterior contra concessão por callback atrasado; a luta foi reexecutada após essa mudança, mas o benchmark não. Não é benchmark de sessão longa nem de TCL física. |

As gravações de testes estão sob `.godot/m5g-*.log`, cache local. Alguns testes emitem o diagnóstico histórico de certificados e avisos ObjectDB ao terminar; isso não demonstra causa nova nem resolução da ressalva histórica.

## Evidências e limites restantes

Vinte capturas reais em [tests/evidencias/m5g](evidencias/m5g/) mostram arena, aviso da fase 1, transição, dash do Abade e recompensa nas resoluções 1280×720, 1920×1080, 2560×1440 e 3840×2160. Capturas são quadros de execução automatizada, não avaliação humana. A captura da arena e da recompensa foi inspecionada; revisão visual nas quatro resoluções e dificuldade pertencem ao responsável.

Ainda faltam: prova física de respostas em ambos os lados e mais posições para cada padrão, análise de todas as situações de dash diante de saídas/portas/atalhos e durante todos os trechos das rotas, assim como sessão longa/performance e playtest humano. O exemplo de esquiva demonstra uma posição e tempo, não ausência universal de dano inevitável. A arte provisória usa o Acólito existente e pode não atender à expectativa de uma identidade completamente própria. Até resolver esses pontos, não se declara PASS técnico.

Arquivos principais criados: `scripts/abbey/abbey_progress.gd`, `abbot.gd`, `abbot_visual.gd`, `abbot_arena.gd`; `scenes/abbey/abbot.tscn`, `abbot_arena.tscn`; testes `tests/m5_g_*.gd` e capturas. Modificados: `scripts/abbey/chapter.gd`, `scripts/player/knight_controller.gd`, `scripts/player/knight_visual.gd` e documentação M5-F/M5-G. Outros arquivos locais e UIDs preexistentes preservados. Sem staging, commit, push ou deploy; M6 e ataque aéreo não iniciados.

## Git final

Branch `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`, índice vazio. Na conferência final havia 239 entradas locais no status, incluindo alterações anteriores, UIDs e importações automáticas de evidências; nenhuma seleção para commit foi feita. Os 15 arquivos protegidos foram comparados ao baseline por SHA-256 e não apresentaram divergências. `git diff --check` não apontou erro; Git avisou sobre normalização futura LF/CRLF de `project.godot`. As mudanças permanecem locais.
