# M5-E — lote 05: rotas opcionais

**Resultado parcial: O1 ganhou espaço de capela e retorno pela direita, com travessia física contínua aprovada no teste.** Não foi comprovada uma medição inequívoca de extensão exclusiva do percurso completo, nem foram implementadas as outras cinco ramificações; por isso nenhuma rota recebe PASS integral neste relatório. A avaliação visual e o playtest do responsável também continuam pendentes.

## Matriz de entrega

| Rota | Antes | Realizado neste lote | Métrica e evidência | Estado |
|---|---|---|---|---|
| O1 S2 | Seis patamares e mensagem; retorno pelos mesmos patamares. | Último apoio ampliado de 48 para 120 px; composição de capela usando atlas existente, inscrição reposicionada e descida pela direita ao caminho principal. | Partida pela entrada real, Monge ativo, seis pousos, mensagem, descida, checkpoint e saída S3 passaram. A projeção horizontal da ramificação entre x≈756 e x=1208 é cerca de 452 px, mas se sobrepõe horizontalmente à espinha e **não é nova extensão horizontal do mapa**. Comprimento geométrico exclusivo completo não apurado. | PARTIAL |
| O2 S3 | Inscrição; sem ramificação. | Nenhuma geometria instalada. | Esboço anterior deixa 0–24 px abaixo da laje sobre a escadaria. Alternativa preliminar abaixo. | PARTIAL |
| O3 S5 | Inscrição; sem ramificação. | Nenhuma geometria instalada. | Esboço anterior chega a 4 px de folga sobre o piso; teto também limita o espaço. Alternativa preliminar abaixo. | PARTIAL |
| O4 S7 | Inscrição; primeiro salto isolado possível. | Nenhuma geometria instalada. | O primeiro apoio antes proposto limita o salto normal do corredor sob ele a 4 px em fixture. | PARTIAL |
| O5 S9 | Inscrição; primeiro salto isolado possível. | Nenhuma geometria instalada. | O primeiro apoio antes proposto limita o salto normal do corredor sob ele a 4 px em fixture; teto existente e CP também precisam ser considerados. | PARTIAL |
| O6 S10 | Inscrição; primeiro salto isolado possível. | Nenhuma geometria instalada. | O primeiro apoio antes proposto limita o salto normal do corredor sob ele a 4 px em fixture; há Pêndulo adiante. | PARTIAL |

Os resultados dos ensaios de colisão não demonstram que todos os projetos alternativos para O2–O6 são inviáveis. Eles demonstram que esses apoios candidatos específicos alteram o salto na espinha, e portanto não foram instalados. Continuar exige um percurso diferente e testes integrados; não foi identificada necessidade de alterar o movimento global nem solicitado arquivo protegido.

## O1: geometria, medições e prova

O último sólido opcional passou de `Rect2(1088,108,48,12)` a `Rect2(1088,108,120,12)`; as outras cinco plataformas do percurso permanecem nas coordenadas anteriores. A mensagem da capela acompanha a placa em `(1148,108)`. A descida no lado direito desemboca no piso principal, próximo de `(1219,228)`; para ativar o CP o teste retornou à esquerda antes de avançar a S3. Não houve mudança nos retângulos da espinha, checkpoints, controle ou inimigos.

No ensaio, a trajetória de x≈756 até o pouso após a descida acumulou **844,73 px de movimento bidimensional** e **461,99 px de movimento horizontal absoluto**. O primeiro soma subidas, quedas, arcos de salto e eventuais deslocamentos repetidos; o segundo também pode incluir repetições. Não somar nenhum dos dois como nova extensão do mapa. A projeção horizontal x≈756–1208 (≈452 px) caracteriza o percurso superior, mas ocupa a mesma faixa x da rota principal em outra altura e não é comprimento geométrico exclusivo validado. Deslocamento separado de ida, descida e trecho repetido até o CP não foi medido; extensão opcional agregada comparável aos **3.000 px históricos propostos** permanece indeterminada. O valor principal histórico de **17.360,42 px** não foi novamente medido nesta etapa.

`tests/m5_e_lote05_o1_test.gd` executou entradas reais na cena da Abadia: entrada normal de S2 pelo controlador, região do Monge com ameaça ativa, bifurcação, seis patamares, Votos sem Nome, inscrição da capela, descida à direita, CP e transição real para S3. Não houve reposicionamento após a entrada; o ensaio terminou sem falhas. Alguns saltos ainda exigem soltar a direção para pousar: o patamar final foi ampliado, mas não foram demonstradas margens amplas de execução nos apoios anteriores. Um ensaio não comprova ausência universal de softlocks.

Após a última alteração artística foram capturadas imagens em 1280×720, 1920×1080, 2560×1440 e 3840×2160, no destino após a travessia. São quadros parados, não uma prova visual contínua em cada resolução. Evidências em `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5e-lote05-definitivo/capela-{largura}x{altura}.png`. A aparência, leitura da entrada e conforto dos saltos precisam de playtest.

## Alternativas para O2 e O3 — ainda não instaladas

Os seguintes esboços são diferentes dos anteriores, em coordenadas locais; são propostas a testar, não geometria aprovada como segura. O uso de superfícies unidirecionais opcionais é apenas uma hipótese para preservar subida através delas, e precisa ser compatível com o jogo e com os saltos reais. Não há teste que prove retorno, câmera ou passagem principal com elas.

- **O2 S3:** possível entrada perto de `(800,372)`, apoios candidatos `Rect2(792,340,36,10)`, `Rect2(842,316,36,10)` e `Rect2(892,292,36,10)`. Antes de aplicar: provar compatibilidade com degraus ascendentes, passagem do corpo, apoio unidirecional, retorno, câmera e posição do Pêndulo. Seria necessária uma câmara ou galeria distinta além desses apoios.
- **O3 S5:** possível entrada perto de `(530,420)`, apoios candidatos `Rect2(520,388,48,10)`, `Rect2(572,412,48,10)` e `Rect2(624,436,48,10)`. A transição entre degraus e o teto acima podem invalidá-los; é necessária prova de folga com personagem, retorno e Comporta. A câmara do ossuário ainda precisa de espaço e desenho próprios.

Para O4–O6, o teste `m5_e_lote05_clearance_fixture.gd` instalou temporariamente cada primeiro apoio do esboço anterior e fez Aren saltar a partir do piso sob ele. Em S7 `(860,284,48,12)`, S9 `(1100,212,48,12)` e S10 `(680,260,48,12)`, o salto atingiu aproximadamente **4 px**, contra cerca de **41 px** na medida histórica sem essa laje. Estas são fixtures com posição sintética e não provas de percurso desde a entrada. O desenho precisa manter o salto da espinha e incluir acesso, retorno e percurso completos antes de instalar sólidos permanentes.

## Regressão e integridade

- Suíte local das cinco inscrições: 36 verificações sem falhas; distribuição M5-C3: 157/157. Ambas foram executadas antes do último ajuste puramente gráfico da capela; a prova O1 e as capturas foram repetidas depois dele.
- Logs: `.godot/m5e-lote05-definitivo.log`, `.godot/m5e-lote05-clearance.log`, `.godot/m5e-lote05-m5_e_lote02_test.log` e `.godot/m5e-lote05-m5_c3_distribution_test.log`. A Godot registrou o diagnóstico conhecido de certificados e aviso ObjectDB na saída; não houve investigação nova.
- Arquivos alterados nesta etapa: `scripts/abbey/m5e_o1_chapel.gd`, `scripts/abbey/chapter.gd`, `tests/m5_e_lote05_o1_test.gd`, `tests/m5_e_lote05_clearance_fixture.gd` e este relatório. Foram preservadas as alterações preexistentes e o planejamento M5-E.
- Os 15 hashes protegidos foram conferidos. Sem staging, commit, push ou deploy; índice vazio. Atalhos e M5-F não iniciados.
