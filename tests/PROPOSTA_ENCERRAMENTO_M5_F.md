# M5-F — revisão aprovada e encerramento administrativo com ressalvas

> **Homologação posterior M5-F:** o responsável informou “playtest ok” e homologou o M5-F com as ressalvas documentadas. O mínimo físico global de 12.227,52 px continua não comprovado e não bloqueante; o modelo horizontal não é distância física. M5-C3, ObjectDB e o pico histórico de 183,878 ms permanecem registrados. Esta informação não representa nova execução automatizada.

**Situação:** o responsável aprovou expressamente a revisão do critério de distância e considerou atendido o critério funcional dos atalhos nos cenários ensaiados. O M5-F foi **homologado pelo responsável com ressalvas**, após o playtest informado; M5-E permanece homologado. O [relatório M5-F](VALIDACAO_M5_F.md) e o [FIX01](VALIDACAO_M5_F_FIX01.md) mantêm seus vereditos históricos e evidências, sem reclassificar resultados inconclusivos como PASS.

## Critério original e evidências

O planejamento original, [seção 22](../docs/PLANEJAMENTO_CAPITULO_02.md), prevê caminho principal mínimo de 12.227,52 px, arredondado para 12.228 px no aceite, inclusive depois de desbloqueados os atalhos. Esse requisito é preservado como **referência original não demonstrada**, não é apagado ou considerado medido e cumprido.

| Questão | Evidência | Situação |
|---|---|---|
| Funcionamento e progressão | Três pares testados nos dois sentidos, abertura pelo lado avançado, visita a S10 antes de A3, morte e retorno; F7 em fixture. | Comprovado nos cenários ensaiados; M5-E aprovado pelo responsável. |
| Utilidade prática | Economia física nos ensaios separados: S4↔S3 246,97 px; S8↔S7 185,74 px; S11↔S9 573,50 px. | Vantagem individual observada; não mede a economia de uma jornada global. |
| Grafo horizontal | Dijkstra no modelo de centros de porta e projeção horizontal: primeira ida 14.528 px; com atalhos abertos 13.766 px. | Ótimo **desse modelo**, não distância física global nem limite garantido. |
| Menor caminho físico global | Arcos, colisões, tolerâncias das portas e ramificações não estão todos modelados em pesos físicos equivalentes. | **Não demonstrado**; a diferença de 762 px do modelo não é economia real comprovada. |

## Revisão aprovada pelo responsável

Para o **aceite funcional dos atalhos no M5-F**, o responsável considerou atendidas a integridade de progressão e a utilidade comprovadas nos cenários executados; o playtest final do marco continua pendente. A prova de que o menor caminho físico global continua acima de 12.227,52 px é agora **limitação conhecida não bloqueante**, sem afirmar que foi satisfeita. Não se propõe alterar geometria ou gameplay nem fazer FIX02 para produzir essa prova.

Justificativa: há evidência física e avaliação humana anterior dos atalhos, com vantagem de cada par, retorno e primeira visita obrigatória preservados; a ausência de ótimo físico global não identifica, por si, defeito que afete o jogador. A proposta mantém transparência sobre a incerteza e permite priorizar problemas reais. Caso haja posteriormente evidência de regressão de progressão ou atalho sem utilidade, a questão funcional deve ser reavaliada.

**Decisão registrada:** o responsável aprovou expressamente a substituição da prova do mínimo global como condição bloqueante pelo critério funcional acima. Esta decisão não constitui homologação final do M5-F.

## Consolidação e demais pendências

- Jornada física principal 1→12→1 com ameaças ativas concluída; sete checkpoints abrangidos pela suíte de distribuição **157/157**. O1–O6 foram testados e homologados no M5-E; A1–A3 foram ensaiados com suas condições de sessão.
- FIX01: falha S8 reproduzida em automação que não combatia/aguardava ameaças; origem exata do dano não registrada. Benchmark de roteiro corrigido, com ameaças ativas e assertivas mantidas: **24/24**. M0 14 verificações, M1 36/36, M2 59/59; composição 189/189, continuidade 118/118 e display 38/38, conforme relatórios.
- 184 capturas dinâmicas em quatro resoluções na espinha, amostras adicionais de O2 e A3; não constituem vídeo contínuo nem avaliação humana exaustiva. O teste de queda dos atalhos foi induzido por posição; a jornada única combinando todos os opcionais, atalhos, morte e queda ainda não foi demonstrada. A avaliação de legibilidade, transições e conforto é parte do **playtest final pendente**, sem presumir falha funcional.
- A candidata com `project.godot` do HEAD importou, iniciou e passou nas verificações documentadas; os parâmetros comparados coincidiram com a configuração local. O manifesto e a escolha da captura A1 divergente precisam ser conferidos antes de uma futura versão registrada. Isso é pendência de **reprodutibilidade/versionamento**, não prova de defeito de jogo; não afirmar que um commit inexistente esteja validado.
- M5-C3: sete encontros combinados encerrados administrativamente com ressalvas; S11 permanece para revisão posterior. ObjectDB permanece com diagnóstico sem causa conclusiva. Pico isolado M5-D de 183,878 ms segue não bloqueante por si; FIX01 registrou outro pico geral sem causa atribuída e amostras de travessia separadas. Não reabrir essas auditorias sem evidência nova.

Com base nos registros revisados, **não há outro defeito crítico reproduzido conhecido** que imponha correção de gameplay nesta etapa. Isso não converte lacunas de cobertura em provas aprovadas: o playtest final e a definição da candidata seguem pendentes. Posteriormente, o responsável informou “playtest ok” e homologou o M5-F com ressalvas; não são inferidos resultados individuais para itens do checklist. A Abadia ainda não estará concluída sem o chefe proposto em [M5-G](../docs/PLANEJAMENTO_M5_G_ABADE.md).

Nenhum novo teste da engine ou benchmark foi executado no registro desta aprovação. Sem staging, commit, push ou deploy.
