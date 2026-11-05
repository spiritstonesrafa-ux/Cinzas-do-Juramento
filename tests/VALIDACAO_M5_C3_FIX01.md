# M5-C3 FIX01 — Jornada da Abadia

**FIX01 BLOQUEADO.** A causa do setor 8 foi reproduzida e a jornada ativa passou em ambos os sentidos. A validação individual dos encontros críticos e do ciclo de vida de projéteis ainda é incompleta, por isso o aceite técnico permanece aberto.

O trabalho começou e terminou em `main`, HEAD `cda7e40b689e4e7197d2eccfb53e9fbd357032d0`, com índice vazio. O hash dos 15 arquivos preexistentes corresponde ao baseline anterior. A correção cria apenas `tests/m5_c3_journey_test.gd` e este relatório, além de atualizar o relatório do M5-C3. A distribuição mantém 11 inimigos e nove perigos. Nenhuma alteração de gameplay, cena ou geometria foi feita nesta rodada.

## Reprodução e correção

Godot 4.7.2, cena `res://scenes/abbey/abbey_chapter.tscn`, física a 60 Hz. Não há sorteio explícito no controlador. No diretório do projeto, os comandos usaram a mesma base `--headless --path . --fixed-fps 60 --log-file <log>`. O argumento `--script` selecionou:

- `res://tests/abbey_chapter_test.gd`, original intacto, saída 1, 789 falhas em 2.299 verificações. Primeira falha em S8. O teste original isola o piloto, mas deixa as instâncias novas ativas e foi escrito para medir navegação estrutural.
- `journey-red.gd`, cópia externa do teste novo antes da correção. Saída 1. Todas as ameaças estavam ativas, inclusive as do piloto. A última transição concluída foi 7→8. No quadro 485 da Ponte dos Penitentes, Aren estava em (841,58; 281,45) local, olhando à direita, fora do chão, com velocidade zerada pela morte e HP 1→0. CP4 ativo e câmera em (29538; 262). O Penitente em x≈528 estava em patrulha e com 2 HP. A Comporta em (850; 300) estava em ataque. A hitbox já estava desligada no snapshot pós-morte pelo desarme da sala. A última ação foi avançar.
- `res://tests/m5_c3_journey_test.gd`, versão corrigida, saída 0. O controlador solta o movimento e o salto antes da zona de perigo durante o aviso e o ataque. Retoma a marcha depois da fase ativa e usa pulsos da ação de espada. A geometria continua sendo transposta pelas ações normais. O teste registra entradas, HP, checkpoint e saída, e confirma a liberação da sala anterior por referência fraca.

A Comporta interrompeu uma trajetória que entrou em sua área de dano com 1 HP. A espera controlada permitiu cruzar S8 nos dois sentidos com 3 HP e sem perder vida. Um ensaio intermediário que só esperava a Comporta passou S8 mas morreu diante do Pêndulo em S10. A versão final aplica a espera também a Pêndulo e Jato, respeitando o deslocamento da área de ataque do Jato.

| Hipótese | Evidência | Resultado |
|---|---|---|
| Automação | Mantinha avanço no aviso. A espera corrigiu a travessia sem mudar o jogo | Confirmada |
| Posicionamento | S8 atravessado em ambos os sentidos sem dano pela estratégia testada | Excluído como bloqueio inevitável nessa prova |
| Combate/hitbox | Dano fatal junto da Comporta em fase ativa. Espera evita o dano | Compatível com o mecanismo. Correspondência quadro a quadro não auditada |
| Morte/respawn | A morte encerrou o roteiro antes do respawn. Testes separados verificaram os sete CPs | Morte confirmada. Defeito de respawn não observado |
| Carregamento | Transições corretas e sala anterior liberada na jornada verde | Excluído como causa observada |
| Softlock | Os dois acessos da ponte foram atravessados com todas as ameaças funcionais | Excluído no cenário reproduzido |

## Jornada ativa

Entradas em x=48 na ida e largura−48 na volta. As saídas intermediárias são x=largura−16 na ida e x=16 na volta. S12 usa o marco de fim, e S1 termina ao alcançar a borda esquerda. Todas as ameaças ficaram habilitadas. Nenhum teleporte, recuperação artificial de vida ou alteração de colisões foi usado nesta jornada. A tabela indica o elenco encontrado no trajeto, sem inferir derrota de cada inimigo.

| Setor | Entrada ida / volta (x) | Ameaças | Ida quadros e HP | Volta quadros e HP |
|---|---:|---|---|---|
| 1 Átrio dos Votos | 48 / 976 | Área de respiro | 586 · 5→5 | 585 · 1→1 |
| 2 Claustro Fraturado | 48 / 1232 | Monge | 776 · 5→5 | 751 · 1→1 |
| 3 Escadaria dos Contrapesos | 48 / 1168 | Pêndulo | 875 · 5→5 | 789 · 1→1 |
| 4 Dormitório das Vigílias | 48 / 1168 | Acólito | 694 · 5→4 | 745 · 1→1 |
| 5 Cisternas Votivas | 48 / 1296 | Comporta e Acólito | 854 · 4→3 | 881 · 1→1 |
| 6 Galeria dos Turíbulos | 48 / 1232 | Monge, Prensa e Jato | 751 · 3→3 | 782 · 2→1 |
| 7 Fundição dos Sinos | 48 / 1424 | Vigia, Pêndulo e Monge | 881 · 3→3 | 1001 · 2→2 |
| 8 Ponte dos Penitentes | 48 / 1168 | Penitente e Comporta | 759 · 3→3 | 760 · 2→2 |
| 9 Arquivo dos Juramentos | 48 / 1296 | Acólito e Jato | 836 · 3→2 | 771 · 2→2 |
| 10 Jardim Suspenso | 48 / 1168 | Penitente e Pêndulo | 817 · 2→2 | 802 · 2→2 |
| 11 Campanário Exterior | 48 / 1232 | Vigia e Comporta | 884 · 2→2 | 792 · 2→2 |
| 12 Coro das Correntes | 48 / 1360 | Monge | 830 · 2→2 | 856 · 2→2 |

## Integração, gráficos e regressão

- A suíte de distribuição passou 157/157, incluindo ativação dos sete checkpoints, morte induzida, respawn e espada contra os quatro arquétipos com recuperação preparada. A jornada ativa acionou todos os sete checkpoints, completou 22 transições entre salas e terminou com 1 HP. A prova contínua inclui as combinações da matriz, mas não isola ataque, janela segura e recuo de cada encontro.
- Em execução estrutural separada, a cópia externa anterior com ameaças isoladas passou 2.299/2.299 e mediu 17.360,4052 px. A diferença para 17.360,42 px é de 0,0148 px. Este resultado mede geometria.
- Passaram as suítes smoke 14, combate 36, sobrevivência 59, Guardião 59/152/59, piloto 357, estrutura 105, M5-C1 41/46/116/78, M5-C2 115/239, continuidade 118 e teto 7. Os resultados se sobrepõem. A jornada original continua falhando pela limitação descrita.
- Capturas estáticas dos 12 setores em 1920×1080 e do S8 também em 1280×720, 2560×1440 e 3840×2160. Na montagem dos 12 setores, HUD, terreno e enquadramento estavam visíveis, com atores e perigos presentes nas amostras correspondentes. A montagem não cobre todos os avisos em movimento, toda a arte de transição nem teste em TV.
- A correção está restrita ao controlador de testes. O desempenho anterior permanece como dado histórico, sem benchmark novo. Os avisos de certificados voltaram. Houve aviso ObjectDB de três objetos na reprodução focada e quatro na regressão estrutural. A liberação da sala na jornada foi verificada. Projéteis individuais, callbacks e crescimento em ciclos prolongados não foram medidos separadamente, portanto não há diagnóstico novo conclusivo sobre retenção.
- Evidências em `m5c3-fix01`, incluindo `original.log`, `red.log`, `green.log`, `structural.log`, `distribution.log`, `regression-results.json`, os PNGs e `montage.png`. Sem staging, commit ou push.

## Checklist humano

Na cena da Abadia via F6, marcar PASSOU / FALHOU / NÃO TESTADO para ida e volta, avisos e janelas de espera, combate e recuo, entradas e saídas, sete checkpoints, morte e respawn, qualidade visual e fluidez 4K. Em S8, aproximar-se da Comporta, esperar o fim do ataque antes de cruzar e repetir no retorno. Verificar especialmente o espaço de recuo no vão anterior e o Penitente. Testar também as combinações nas Cisternas, Galeria, Fundição, Arquivo, Jardim e Campanário.
