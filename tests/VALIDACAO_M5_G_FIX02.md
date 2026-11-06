# M5-G FIX02 — redesign e ritmo do Abade

> Nota da consolidação: as capturas históricas foram produzidas conforme descrito; a seleção Git mantém apenas as imagens representativas vinculadas neste relatório. As demais permanecem locais.

**Resultado: PARTIAL.** Há implementação jogável e testes dirigidos aprovados, mas ainda falta avaliação humana da arte, da legibilidade em movimento e da dificuldade, além de medição gráfica de desempenho em 4K e inspeção completa de todas as poses. M5-G não está homologado.

## Redesign

As duas referências efetivamente anexadas mostram o mesmo Abade nas duas fases; não foi recebida uma terceira imagem. O recurso original `assets/art/m5g/abbot_fix02.png` foi gerado com a ferramenta integrada de imagens a partir delas, usando como direção vestes vinho e marfim, mitra, correntes, halo e energia violeta. Uma segunda geração corrigiu o enquadramento; a região do dash foi estendida para incluir o manto. O atlas ampliado do Acólito deixou de ser usado pelo Abade.

Há 12 poses correspondentes a repouso, perseguição, preparação e execução de corrente e varredura, preparação e execução do dash, recuperação, dano, transformação e derrota. A caminhada alterna duas poses; as demais são poses de estado, com efeitos temporais, e não animações quadro a quadro completas. A transição tem pose e cor violetas, sem novo dano. Não foi acrescentado áudio.

O recurso é desenhado na resolução interna e espelhado conforme a direção; os danos continuam definidos pela fonte já existente. Em uma primeira captura o manto foi cortado; a região foi corrigida e a captura gráfica repetida. Ainda não se inspecionou manualmente cada pose e espelhamento em cada resolução.

## Ritmo e justiça

| Parâmetro | Antes | Agora |
| --- | ---: | ---: |
| HP | 10 | 10 |
| Dano | 1 | 1 |
| Perseguição | 32 px/s | 42 px/s |
| Dash | 180 px/s | 180 px/s |
| Aviso corrente/varredura | 0,95 s | 0,85 s |
| Aviso dash | 1,15 s | 1,15 s |
| Recuperação fase 1 | 1,25 s | 1,05 s |
| Recuperação fase 2 | 1,25 s | 0,90 s |

A sequência continua limitada a um ataque por aviso, seguido de recuperação: na fase 2, dash e corrente alternam. A frequência aumentou pela recuperação menor e perseguição mais rápida; não foi incluído novo padrão ou removida a janela de reação. A transição mantém sua recuperação anterior de 1,05 s. O aumento de pressão é uma inferência dos parâmetros; intensidade, justiça percebida e diversão dependem de playtest.

## Efeitos e preservação

Ambos os dashes têm imagens residuais com duração máxima de 0,18 s e limite de cinco amostras, desenhadas sem criação de nós. Aren usa pose de deslocamento, rastro escuro violeta e partículas pequenas de início/fim. O Abade apresenta preparação de corrente, pose com manto em movimento, rastro violeta e partículas de recuperação. Não houve mudanças na física de Aren, desbloqueio, Shift, persistência, colisões, dano ou invulnerabilidade.

## Testes executados

Testes em cópia isolada do projeto com Godot 4.7.2 e perfis APPDATA separados, sem acessar saves do responsável. A importação terminou com código 0. A engine registrou o diagnóstico de certificados e, ao fechar testes, o aviso histórico de três instâncias ObjectDB.

- Matriz física de direção/justiça: **64/64**, corrente, varredura e dash em distâncias e paredes, ambos os lados; não prova justiça universal.
- Jornada contínua dos 12 setores até vitória com ataques e ameaças ativos, sem dash de Aren: passou, restando 2 de vida; a vitória automática não prova que a luta seja divertida ou fácil.
- Morte, CP7 e reentrada: passou; colisão contra Aren e alternância dash–corrente–dash: passaram.
- Dash integrado, borda de S8 e dano de comporta: passou após repetição com perfil que tinha recompensa válida. Uma primeira execução em perfil sem recompensa falhou por configuração do teste.
- Persistência em novo processo, cooldown, colisão com parede e ausência de invulnerabilidade: passou após definir `M5G_EXPECT=1`; uma primeira execução omitiu essa opção e comparou o perfil premiado com a expectativa de bloqueio.
- Capturas gráficas da luta e vitória em 1280×720, 1920×1080, 2560×1440 e 3840×2160: concluídas. Sequência do dash de Aren em ambas as direções: capturada e confirmou criação e expiração de rastros. O roteiro gráfico da sequência do Abade também passou; sua captura tem somente amostras esparsas, não uma gravação contínua suficiente para avaliar toda a animação.
- Amostragem de desempenho headless: 716 quadros, média 16,662 ms, p95 20,801 ms e máximo 21,253 ms; não mede renderização de GPU nem garante desempenho em 4K.

Capturas reais: [arena](evidencias/m5g-fix02/arena_1280x720.png), [transição](evidencias/m5g-fix02/transicao_1280x720.png), [dash do Abade](evidencias/m5g-fix02/dash_abade_1280x720.png), [dash de Aren](evidencias/m5g-fix02/aren_direita_00.png). A pasta contém as quatro resoluções e a sequência de Aren. Comparação anterior: [Acólito e Abade provisório](evidencias/m5g-fix01/comparacao_fase1_1280x720.png). As capturas do Abade foram feitas em luta acionada por controles; a sequência de Aren parte de perfil de teste com vitória legítima.

## Pendências e playtest

Verificar a leitura e o enquadramento de todas as poses, em ambas as direções e nas quatro resoluções; fazer uma sequência temporal suficiente do dash do Abade e medir desempenho gráfico em 4K. Testar manualmente: entrar pela saída do setor 12, perceber aviso e direção perto e longe de paredes, defender com caminhada/salto e punir na recuperação, observar a transição e vencer usando somente ataque terrestre; conferir morte/reentrada, recompensa e dash de Aren para ambos os lados, em parede e borda, além de persistência após reiniciar. Aprovação visual, dificuldade e sensação permanecem do responsável.

## Arquivos e segurança

Alterados nesta etapa: `scripts/abbey/abbot.gd`, `scripts/abbey/abbot_visual.gd`, `scripts/player/knight_visual.gd`; criados `assets/art/m5g/abbot_fix02.png`, `tests/m5_g_fix02_dash_visual.gd`, `tests/m5_g_fix02_boss_sequence.gd`, capturas em `tests/evidencias/m5g-fix02/` e este relatório. Esses scripts de gameplay já possuíam alterações locais anteriores, preservadas. Não houve alterações na física de Aren, nos 15 arquivos protegidos ou nos sistemas de progressão. Os 15 hashes coincidiram com `m5c3-20261104-01/baseline.json` antes e depois da implementação.

Branch `main`, HEAD `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`; índice vazio. `git diff --check` não reportou erros, com aviso preexistente de normalização de linhas em `project.godot`. As alterações locais preexistentes permanecem. Sem staging, commit, push, deploy, M6 ou ataque aéreo. Ressalvas históricas de M5-C3, ObjectDB e desempenho permanecem.
