# M5-D — amostras de acabamento, avaliação pendente

> **Homologação final:** o responsável informou que realizou o playtest, confirmou que está tudo OK e aprovou oficialmente o **M5-D visual e funcionalmente**. Este registro preserva as avaliações e os resultados técnicos históricos abaixo. Nenhuma nova execução da engine foi realizada para registrar a homologação.

O pico isolado de **183,878 ms** observado no benchmark automatizado em 4K fica registrado como observação de desempenho **não bloqueante**. O ensaio incluiu carga inicial e a causa do pico não foi determinada. Permanecem os valores registrados de 59,30 FPS médios e p95 de 16,955 ms, sem tratar o benchmark automatizado como medição do playtest. A ressalva histórica ObjectDB segue aberta. As pendências M5-C3, incluindo a combinação avançada do Campanário para revisão posterior sem bloquear o roadmap, continuam em [ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md](ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md).

### Inventário da entrega M5-D, sem staging

| Arquivo | Pertinência e estado |
|---|---|
| `scripts/abbey/chapter_art.gd` | Código visual do acabamento M5-D, modificado desde o HEAD. |
| `docs/PLANEJAMENTO_M5_D.md` | Planejamento e estado do M5-D, arquivo local não rastreado criado antes deste encerramento. |
| `tests/VALIDACAO_M5_D.md` | Relatório, resultados e homologação M5-D, arquivo local não rastreado. |
| `README.md` | Cabeçalho de estado atualizado. Arquivo compartilhado com histórico e alterações documentais preexistentes; seu diff deve ser revisado por conteúdo em eventual commit. |
| `ROADMAP.md` | Estado, homologação e próximo marco atualizados. Arquivo compartilhado com histórico e alterações documentais preexistentes; seu diff deve ser revisado por conteúdo em eventual commit. |

As alterações M5-C3 anteriores incluem `scripts/abbey/chapter.gd`, `scripts/abbey/chapter_sector.gd`, `scripts/abbey/m5c3_distribution.gd` e seu `.uid`, as suítes `tests/m5_c3_*` e seus `.uid` presentes, `tests/VALIDACAO_M5_C3.md`, relatórios FIX01–FIX05/RCA01 e `tests/ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md`. Não pertencem exclusivamente ao M5-D. O `project.godot` modificado e os 14 arquivos não rastreados anteriores constituem os 15 arquivos protegidos e foram preservados. As capturas e logs externos listados abaixo são evidências fora do repositório, não arquivos registrados no Git. Este inventário é para revisão e não prepara o índice.

O próximo marco previsto é M5-E, dedicado a exploração, segredos e atalhos, sujeito à autorização de implementação e aos requisitos próprios. Não foi iniciado neste encerramento. Branch `main`, HEAD `cda7e40b689e4e7197d2eccfb53e9fbd357032d0`. Sem staging, commit, push ou deploy.

> **Atualização posterior:** o responsável aprovou preliminarmente as amostras dos setores 3 e 4 como direção para continuidade. O acabamento foi aplicado nos trechos abaixo e está disponível para avaliação final. M5-D permanece pendente de homologação. Os resultados da seção de amostras são históricos; a seção de continuidade registra a execução após as últimas alterações.

## Continuidade autorizada e estado para avaliação

Na continuação, a alvenaria dos pisos recebeu tonalidades discretas próprias do ambiente, aplicadas somente dentro dos sólidos. Os pisos dos conectores em S2/S6 foram contemplados pelo código existente; os fundos dos pilotos continuam com seus proprietários originais. A faixa escura do intradorso, aprovada preliminarmente em S4, foi estendida aos tetos dos setores 5 e 9. Na Escadaria e no Campanário, silhuetas de contrapesos decorativos repetidos foram removidas para distinguir os elementos ofensivos; a arquitetura, correntes e sinos dos fundos foram mantidos. Em S1, S9 e S12, a repetição de estátuas decorativas foi reduzida. S5, S7 e S10 mantiveram as cores características de cisterna, bronze e vegetação, respectivamente.

Não foram produzidos novos PNGs ou alterados atlas, fundos, scripts dos atores, colisões ou cenas. As mudanças estão em `scripts/abbey/chapter_art.gd` e reutilizam o atlas com proveniência já registrada em `assets/art/m5a/PROVENANCE.md`. S2 e S6 preservam os fundos do piloto, S4/S5/S9 preservam a geometria dos tetos. As amostras anteriores continuam parte da alteração atual.

### Resultado de verificação após as últimas alterações

- `abbey_chapter_visual_test.gd`: **189/189**, com 50 capturas, incluindo os 12 setores nas resoluções 1280×720, 1920×1080, 2560×1440 e 3840×2160 e duas fixtures extras em 4K. A montagem `final-contact.png` foi inspecionada. As capturas são enquadramentos de teste e não equivalem a uma aprovação artística humana.
- Teste gráfico adicional com entrada de movimento e salto no Dormitório em cada uma das quatro resoluções: quatro imagens geradas com Aren no ar e deslocamento observado. `abbey_ceiling_stability_test.gd`: **7/7**, com câmera em movimento nos setores 4, 5 e 9. A inspeção visual de movimento foi limitada a esses cenários, não uma avaliação humana contínua de toda a Abadia.
- `abbey_continuity_test.gd`: **118/118**, backend gráfico. As verificações cobrem as faixas previstas dos setores 2 e 6.
- `m5_c3_distribution_test.gd`: **157/157**. `m5_c3_journey_test.gd`: ida 1→12 e volta 12→1 com ameaças ativas, sem morte e com 1 HP ao final. A jornada é automatizada e não homologa o ritmo para um jogador humano.
- Regressões: smoke **14**, combate **36**, sobrevivência **59**, chefe **59/152/59**, piloto **357**, estrutura **105**, M5-C1 **41/46/116/78** e M5-C2 **115/239**, todas com código de saída 0. As suítes se sobrepõem e não devem ser somadas como verificações independentes.
- Benchmark gráfico automatizado em janela **3840×2160**, RTX 2060 SUPER, Godot 4.7.2 Compatibility, 30 s: **59,30 FPS médios**, **p95 16,955 ms**, **máximo 183,878 ms**, até 97 nós e 1.701 objetos. O cenário usa os setores 2, 7 e 11, transições e restauração de vida por fixture. Um ensaio de 10 s concentrado no setor 2 registrou **59,10 FPS**, **p95 16,950 ms** e **máximo 181,216 ms**. Ambos incluem carga inicial; a medição não separa o instante do pico, que permanece sem causa estabelecida. Os números não substituem avaliação na TCL física.
- Os testes registraram o diagnóstico de certificados e avisos ObjectDB de 3 ou 4 instâncias ao encerrar. A ressalva histórica permanece aberta, sem nova conclusão sobre sua causa.

Os logs, as 50 capturas, as imagens de movimento, `final-contact.png` e o inventário de hashes estão em `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5d-final-20261105-01/`. O benchmark reutilizou o script externo do ensaio M5-C3 para manter a metodologia comparável; o ensaio curto foi adaptado para um setor.

Após as execuções, a Godot gerou os arquivos `tests/m5_c3_journey_test.gd.uid` e `tests/m5_c3_lifecycle_test.gd.uid`, que permanecem locais. Comparando os hashes do estado local inicial desta continuação, foram alterados somente `README.md`, `ROADMAP.md`, `scripts/abbey/chapter_art.gd`, `docs/PLANEJAMENTO_M5_D.md` e este relatório. Os 15 arquivos protegidos foram conferidos novamente sem divergência.

### Checklist para avaliação final

Abrir `scenes/abbey/abbey_chapter.tscn` na Godot 4.7.2 e pressionar F6. Usar A/D, Espaço e J; F7 reinicia a Abadia e F5 abre o Capítulo 1. Percorrer os 12 setores na ida e na volta e registrar PASSOU / FALHOU / NÃO TESTADO para: leitura de piso e teto; contraste de Aren/HUD; avisos de inimigos e mecanismos; destino dos saltos; continuidade visual; checkpoints e respawn; câmera; imagem e fluidez na tela usada. Verificar especialmente S2/S6 em x=960, tetos de S4/S5/S9, pêndulo real na Escadaria, Campanário e área final.

As ressalvas de M5-C3, inclusive a combinação avançada do Campanário para revisão posterior sem bloqueio do roadmap, permanecem em `tests/ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md`. A implementação está preparada para playtest; **M5-D não está homologado nem concluído**. Não houve staging, commit, push ou deploy.

**Estado: implementação parcial, sem homologação.** Foram preparadas duas amostras integradas, na Escadaria dos Contrapesos e no Dormitório das Vigílias. O acabamento dos demais setores aguarda a avaliação das amostras prevista no planejamento. Os resultados abaixo pertencem a esta execução e não aprovam visualmente o marco.

## Baseline e preservação

Início em `C:/PROJETOS/CINZAS DO JURAMENTO`, branch `main`, HEAD `cda7e40b689e4e7197d2eccfb53e9fbd357032d0` e índice vazio. O inventário anterior incluía alterações locais M5-C3 e documentação ainda não commitadas. Os 15 arquivos protegidos foram verificados contra os hashes históricos. As alterações locais existentes foram inventariadas antes da edição em `baseline.json` no diretório de evidências desta etapa.

Nenhum recurso PNG, cena, física, IA, estado de combate, geometria ou checkpoint foi editado nesta execução. O único código visual alterado é `scripts/abbey/chapter_art.gd`. A medida de 17.360,42 px é histórica; a geometria não foi alterada e o percurso não foi medido novamente. A distribuição M5-C3 e o encerramento administrativo com ressalvas continuam registrados nos relatórios anteriores.

## Inventário e direção das amostras

O projeto já usa dez fundos estruturais originais em `assets/art/m5b`, dois fundos dos pilotos e atlas arquitetônico em `assets/art/m5a`, sprites dos três arquétipos em `assets/art/m5c` e mecanismos em `assets/art/m5c2`. As proveniências estão nos arquivos `PROVENANCE.md` dessas pastas. O desenho da região ocorre em `chapter_art.gd`; os pilotos nos setores 2 e 6 seguem responsáveis pelos seus fundos. Os arquivos originais foram reutilizados sem criar ou substituir imagens.

Foram capturados os 12 setores em 1920×1080 antes das alterações e examinada uma montagem de inventário. É uma amostra estática por setor, não uma inspeção completa em movimento. A proposta mantém a paleta fria e a arquitetura existente, preservando detalhes quentes em mecanismos e sinalizações. A tabela é um inventário da direção atual e dos pontos de revisão, não uma aprovação de cada setor.

| Setor | Ambiente e direção existente | Ponto de revisão |
|---|---|---|
| 1 Átrio dos Votos | Recepção monumental em pedra, planos frios | Orientação e leitura do início |
| 2 Claustro Fraturado | Claustro aberto e arcos | Continuidade do fundo do piloto em x=960 |
| 3 Escadaria dos Contrapesos | Escadaria em altura, correntes e mecanismos | Separação entre ornamentos e pêndulo ativo |
| 4 Dormitório das Vigílias | Interior, camas, arcos e alvenaria escura | Diferenciação entre intradorso e piso |
| 5 Cisternas Votivas | Pedras e tons aquosos | Teto e leitura de Comporta/Acólito |
| 6 Galeria dos Turíbulos | Galeria interna, dourados e incenso | Continuidade do piloto em x=960 e avisos |
| 7 Fundição dos Sinos | Arquitetura de oficina e bronze | Leitura de Vigia, pêndulo e Monge |
| 8 Ponte dos Penitentes | Travessia aberta com vãos | Destinos de salto e aviso da Comporta |
| 9 Arquivo dos Juramentos | Galerias e estantes em subida | Teto, projétil e Jato |
| 10 Jardim Suspenso | Vegetação e aqueduto | Separação aprovada de travessia e combate |
| 11 Campanário Exterior | Sinos e contrafortes | Leitura de ameaças. Combinação avançada segue pendente de revisão posterior, sem bloquear roadmap |
| 12 Coro das Correntes | Salão de aproximação e área final | Preparação e legibilidade do checkpoint |

## Implementação das amostras

1. **S3 Escadaria**, amostra aberta em altura. O renderizador repetia em cada patamar uma silhueta de peso suspenso semelhante ao pêndulo ofensivo. A amostra remove essas silhuetas decorativas apenas no S3; o pêndulo ativo, seu desenho e sua colisão continuam próprios do mecanismo homologado. As correntes e a arquitetura já presentes no fundo permanecem.
2. **S4 Dormitório**, amostra interior. Uma faixa escura discreta na parte inferior do intradorso reforça a leitura de teto. Ela acompanha o retângulo de teto do layout e não adiciona colisão, borda clara ou plataforma. A amostra não modifica S5/S9.

As capturas reais foram produzidas com Godot 4.7.2 e backend gráfico OpenGL da RTX 2060 SUPER. Os arquivos `before-S03-1920.png`, `before-S04-1920.png`, `after-S03-1920.png` e `after-S04-1920.png`, além de `inventory-contact.png`, estão em `C:/Users/ovohe/.codex/visualizations/2026/11/03/01a19f0a-ee96-7412-bd99-7c6152fadd40/m5d-20261105-01/`. As capturas usam fixture de posição para enquadrar Aren e ameaças. Não comprovam a qualidade em movimento, nem homologação humana.

## Verificações realizadas

- Renderização gráfica das duas amostras em 1920×1080: cenas abriram e os PNGs foram gerados. As imagens finais foram inspecionadas; o Acólito, seu aviso e Aren estão visíveis no recorte S4. O pêndulo ativo está visível no recorte S3. Não se afirma avaliação de todos os quadros de ataque.
- `tests/abbey_continuity_test.gd`: **118/118**, backend gráfico. O oráculo cobre as faixas previstas, não todas as transições.
- `tests/abbey_ceiling_stability_test.gd`: **7/7**, backend gráfico, incluindo os pontos de S4/S5/S9 durante salto.
- `tests/m5_c3_distribution_test.gd`: **157/157**, headless, incluindo carregamento, pontos de entrada, checkpoints, reinício local e provas preparadas de espada.
- As suítes foram executadas antes do ajuste final que removeu traços decorativos da amostra S3. Após esse ajuste, as duas cenas foram renderizadas novamente; não houve alteração em geometria ou colisões. Os três testes não foram repetidos após essa última mudança puramente visual.
- A engine relatou falha na leitura de certificados e avisos ObjectDB de 3 ou 4 instâncias ao encerrar. A ressalva histórica de origem inconclusiva permanece aberta; não foi feita nova auditoria de vazamento.

## Pendências e checklist

O acabamento dos demais setores, a avaliação em movimento das amostras, capturas finais nas quatro resoluções, benchmark proporcional à implementação final, regressões eventualmente afetadas e playtest humano permanecem pendentes. A matriz de encontros M5-C3 permanece conforme a decisão administrativa do responsável; não foi reaberta nesta etapa.

Para avaliar as amostras, abrir `scenes/abbey/abbey_chapter.tscn` na Godot 4.7.2 e pressionar F6. Usar A/D para andar, Espaço para saltar e J para espada; F7 reinicia a Abadia. No setor 3, verificar se o pêndulo ofensivo se distingue da arquitetura durante aproximação e travessia. No setor 4, observar em movimento e durante saltos se o intradorso continua reconhecível como teto e se o aviso do Acólito permanece claro. Registrar PASSOU / FALHOU / NÃO TESTADO e observações. F5 continua sendo o acesso ao Capítulo 1.

O plano em `docs/PLANEJAMENTO_M5_D.md`, etapa 3, prevê avaliação visual do responsável antes de generalizar as amostras. A implementação de M5-D está parcialmente concluída e aguarda essa avaliação para avançar ao acabamento por lotes. Nenhum staging, commit, push ou deploy foi realizado.
