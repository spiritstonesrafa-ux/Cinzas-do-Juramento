# M5-E — exploração, segredos e atalhos da Abadia Silenciosa

> **Encerramento posterior:** o responsável aprovou em playtest o M5-E visual e funcionalmente, incluindo as seis inscrições, O1–O6 e os três atalhos. Os registros abaixo mantêm o estado histórico de cada lote. Consulte [o encerramento](../tests/ENCERRAMENTO_M5_E.md); M5-F está apenas em preparação.

> **Homologação informada no lote 09:** o responsável aprovou em playtest os seis percursos O1–O6, incluindo visual, movimentação, acessos e retornos. O trabalho dos atalhos está autorizado, com bloqueio de primeira passagem e persistência apenas em sessão; o M5-E completo ainda depende da validação dos atalhos e da homologação final.

> **Atualização do lote 08:** O2 e O3 receberam percursos físicos laterais com provas de acesso e retorno; O4–O6 passaram novamente após exigir salto mantido para entrada. O1–O6 têm PASS técnico nas trajetórias ensaiadas, com playtest do responsável pendente. A aceitação da clareza e conforto do acesso é humana; os três atalhos e M5-F permanecem não iniciados. Ver [VALIDACAO_M5_E_LOTE08.md](../tests/VALIDACAO_M5_E_LOTE08.md).

> **Atualização do lote 07:** foram acrescentadas áreas laterais no fim dos setores 7, 9 e 10, com provas físicas de acesso e retorno e saídas normais pelo piso. As rotas O4–O6 têm PASS técnico nas trajetórias ensaiadas e aguardam avaliação do responsável; O2 e O3 permanecem sem ramificações. Os acessos laterais usam um salto sobre o limiar da saída, comportamento que precisa de atenção no playtest. Ver [VALIDACAO_M5_E_LOTE07.md](../tests/VALIDACAO_M5_E_LOTE07.md). Atalhos e M5-F não foram iniciados.

> **Atualização do lote 06:** O1 tem PASS técnico no escopo da galeria e capela existentes, com travessia completa, retorno, checkpoint, verificação amostral do corredor e uma referência geométrica documentada. A direção visual da capela foi aprovada por captura pelo responsável; o playtest presencial continua pendente. O2–O6 permanecem sem rotas opcionais físicas implementadas. Ver [VALIDACAO_M5_E_LOTE06.md](../tests/VALIDACAO_M5_E_LOTE06.md); a conclusão do M5-E e os atalhos permanecem pendentes.

> **Atualização do lote 04:** O1 recebeu três apoios adicionais e uma inscrição contextual de capela, com teste de ida e volta desde a entrada do setor. Trata-se de uma galeria parcial, ainda sem a câmara/circuito completo ou comprovação da meta histórica de extensão. O2–O6 continuam com inscrições, mas sem ramificações novas: os esboços precisam de validação integrada e redesign. Detalhes em [VALIDACAO_M5_E_LOTE04.md](../tests/VALIDACAO_M5_E_LOTE04.md). Os atalhos não foram iniciados. Esta atualização registra trabalho real e não constitui homologação.

**Planejamento proposto. Implementação, acessibilidade física e homologação pendentes.** O próximo marco busca recompensar observação sem tornar obrigatória a exploração. A base é a Abadia de 12 setores, com M5-D homologado visual e funcionalmente e M5-C3 encerrado administrativamente com ressalvas. O plano não aprova alterações de geometria, estruturas de cena ou sistemas funcionais. Cada alteração dessa natureza deve ser submetida ao responsável antes da implementação, conforme o pedido desta etapa.

## Requisitos e fontes

O [roadmap](../ROADMAP.md) define M5-E como exploração, segredos e atalhos completos. O [planejamento original do Capítulo 2](PLANEJAMENTO_CAPITULO_02.md), seções 8–11, 15 e 21–22, apresenta seis ramos O1–O6, alvo de 3.000 px exclusivos, três atalhos com economia conjunta proposta de até 960 px e sete checkpoints. Os ramos devem ser opcionais, sinalizados e com retorno, sem novo inventário obrigatório, aumento de atributos ou requisito de habilidade nova. O menor caminho principal após atalhos deve respeitar o mínimo histórico de 12.227,52 px, arredondado para 12.228 px no aceite proposto. São metas e desenho preliminar a confirmar no projeto executável, não funcionalidades já entregues.

O [GDD](../GDD.md) valoriza progressão linear, controles justos e narrativa ambiental. Não exige inventário, economia, equipamentos ou habilidades adicionais. A homologação visual e funcional M5-D consta em [VALIDACAO_M5_D.md](../tests/VALIDACAO_M5_D.md). M5-C3 permanece encerrado administrativamente com ressalvas em [seu registro](../tests/ENCERRAMENTO_ADMINISTRATIVO_M5_C3.md). A pendência da combinação avançada S11 segue para revisão posterior sem bloquear o roadmap. A ressalva ObjectDB permanece aberta.

## Diagnóstico da arquitetura real

`scripts/abbey/chapter_layout.gd` fornece larguras, pisos, tetos, orientação, entrada e saída, sete CPs e caminhos das cenas. A origem global do setor de índice zero `id` é `(4096 × id, 0)`. O traçado medido historicamente é 17.360,42 px; a medição física isolada posterior foi 17.360,4052 px. `chapter.gd` mantém Aren e HUD, um setor residente, CPs persistentes na sessão e snapshots por setor. Ao sair salva o estado da sala, na morte limpa os estados e restaura no checkpoint, e queda viva retorna ao início sem cura. A rotina atual `switch_room` aceita apenas índice e sentido e reposiciona Aren na entrada correspondente. A conclusão do setor 12 é estrutural, sem chefe M6.

`chapter_sector.gd` cria `OptionalReserve` nos IDs zero-base 1, 2, 4, 6, 8 e 9, correspondentes aos setores 2, 3, 5, 7, 9 e 10. Esses marcadores usam o piso `main[int(main.size()/2)]` mais `(24,-64)` e **são reservas, não portas nem segredos jogáveis**. `ShortcutReserve` existe nos IDs 3, 7 e 10, com posição `main[0].position+(24,-64)`, sem ligação funcional. O núcleo do piloto S2 possui a descoberta existente `discovered` próxima de `(936,84)`, sem transformá-la automaticamente em um novo ramo O1. Antes de reutilizar qualquer reserva é preciso medir sua relação com teto, câmera, piso, CP e ameaças reais. `m5c3_distribution.gd` integra ameaças locais e o piloto S6 mantém Monge e Prensa.

Não há sistema genérico de portas secundárias, trava persistente, inventário de segredos ou geometria adicional implementados nesses marcadores. Conexão entre setores usa origens separadas por 4.096 px e transições de sala. Uma distância entre origens não é percurso jogável. Os pontos e extensões abaixo são propostas localizadas por referências existentes, não coordenadas de porta nem saltos aprovados.

## Matriz dos 12 setores

As faixas de piso são coordenadas locais y extraídas de `main_surfaces`, com y crescente para baixo. Oportunidades em S2/S3/S5/S7/S9/S10 correspondem a reservas de ramo do código. CP nos setores 2, 3, 5, 7, 9, 11 e 12.

| Setor | Geometria, passagem e ameaças existentes | Oportunidade e restrição |
|---|---|---|
| 1 Átrio dos Votos | Largura 1024, pisos y268–300; sem CP ou nova ameaça; entrada à esquerda e saída à direita | Recepção e pista ambiental. Preservar início seguro e orientação principal. Nenhum ramo proposto. |
| 2 Claustro Fraturado | Largura 1280, piso principal y156–300, plataformas opcionais do piloto, Monge; CP no final | O1 na área reservada do claustro. Diferenciar da descoberta `(936,84)` já existente; proteger fundo contínuo e monumento aprovado. |
| 3 Escadaria dos Contrapesos | Largura 1216, degraus y588→252, Pêndulo; CP no fim | O2 na reserva mediana. Evitar colocá-lo na varredura ou fazer da escada um salto cego. |
| 4 Dormitório das Vigílias | Largura 1216, degraus y252→444 e trechos de teto, Acólito; sem CP | A1 proposto em conexão de serviço com S3. Teto e campo de tiro limitam entrada e saída. |
| 5 Cisternas Votivas | Largura 1344, piso y300→516→444, tetos, Comporta e Acólito; CP no fim | O3 na reserva mediana. Corrente de água é pista estética, não mecânica aquática existente. |
| 6 Galeria dos Turíbulos | Largura 1280, piso y300 e plataformas do piloto em y276; Monge, Prensa e Jato | Sala de transição e respiro; evitar acrescentar entrada sobre mecanismo ou alterar o piloto. |
| 7 Fundição dos Sinos | Largura 1472, pisos y276–348; Vigia, Pêndulo e Monge; CP no fim | O4 na reserva e conexão proposta A2 com S8. Separar fluxo de CP, varredura e combate. |
| 8 Ponte dos Penitentes | Largura 1216, pisos y284–316 e três vãos de 24 px; Penitente e Comporta | A2 proposta com S7. Evitar abertura em borda de vão, pouso obrigatório ou sensor da Comporta. |
| 9 Arquivo dos Juramentos | Largura 1344, pisos y444→228, tetos, Acólito e Jato; CP no fim | O5 na reserva mediana; A3 proposta a partir do lado avançado S11. Preservar teto e leitura do projétil. |
| 10 Jardim Suspenso | Largura 1216, pisos y252–324; Penitente e Pêndulo; sem CP | O6 na reserva. A separação entre travessia e combate foi aprovada pelo responsável. |
| 11 Campanário Exterior | Largura 1280, escadaria y612→252; Vigia e Comporta; CP no fim | A3 proposto com S9. A combinação avançada segue pendência de revisão posterior sem bloquear roadmap. |
| 12 Coro das Correntes | Largura 1408, pisos y228–300; Monge, CP em x1168 e fim estrutural | Preservar últimos 240 px de preparação e espaço do futuro chefe. Nenhuma descoberta obrigatória. |

## Seis oportunidades de descoberta e percurso opcional

As seis propostas refletem os seis ramos nomeados no planejamento histórico e suas reservas na implementação. Prioridade e custo são estimativas de planejamento: A alta, M média, B baixa. Todos os percursos precisam de geometria ou cenas adicionais e aprovação antes de implementar. Os comprimentos são alvos históricos de caminho exclusivo; somente medição física poderá confirmar.

| ID e localização | Pista, objetivo e recompensa | Acesso e retorno propostos | Alvo exclusivo | Prioridade / custo / valor | Dependências e aceite |
|---|---|---|---:|---|---|
| O1 · S2 Capela dos Nomes Riscados, junto à `OptionalReserve` | Nomes raspados e luz suave conduzem a um relevo e vista do pátio | Acesso por patamar visível, circuito de volta ao claustro. A descoberta existente de Votos sem Nome será preservada e identificada separadamente | 360 px | A / M / orientação narrativa | Definir porta e patamares fora do Monge/CP. Testar ida, retorno, câmera e distinção da descoberta já existente. |
| O2 · S3 Câmara do Contrapeso Partido, reserva mediana | Corrente interrompida sugere mecanismo antigo e inscrição de sabotagem | Galeria lateral e saída de serviço a patamar conhecido, sem pousar na varredura do pêndulo | 480 px | M / A / história e exploração vertical | Desenhar apoios compatíveis com salto e câmera. Testar ida/volta, aproximação do perigo e recuperação. |
| O3 · S5 Ossuário Submerso, reserva mediana | Reflexo e inscrição dos votos sugerem câmara baixa | Descida por pisos visíveis e escada de retorno. Água decorativa, sem natação ou novo dano | 560 px | M / A / variedade ambiental | Respeitar tetos, Comporta, Acólito e CP. Validar saltos em ambos sentidos e leitura do aviso. |
| O4 · S7 Molde do Sino Mudo, reserva mediana | Marca de bronze orienta ao molde e monumento | Acesso por lateral da fundição, saída distinta para a espinha quando houver espaço físico aprovado | 420 px | M / A / exploração e encontro opcional | Não alterar IA ou dano. Definir posição segura entre Vigia, Pêndulo, Monge e CP. Testar recuo e saída. |
| O5 · S9 Registro sem Assinatura, reserva mediana | Selo ou alvenaria interrompida conduz a inscrição parcial | Rota lateral com galeria de retorno visível, sem atravessar teto ou Jato | 620 px | M / A / descoberta narrativa | Acólito e projétil ativos. Medir folgas e provar resposta, ida/volta e ausência de sobreposição injusta. |
| O6 · S10 Mirante da Abadia, reserva mediana | Arco iluminado e vegetação direcionam a vista do caminho percorrido | Travessia opcional sem pressão de combate, reconectada à espinha. Preservar separação aprovada | 560 px | A / M / respiro e recompensa visual | Identificar acesso fora do Pêndulo e do Penitente. Testar retorno e câmera em resoluções previstas. |

Cada proposta oferece vista, inscrição ou informação ambiental, sem item, XP ou melhoria de atributos. Um texto contextual ou interação explícita que demande novo sistema deve ser proposto separadamente. Um ramo pode conter uma descoberta, mas **descoberta**, **percurso exclusivo** e **atalho** são conceitos distintos. Os seis valores somam 3.000 px como alvo, não como medição do estado atual.

## Três atalhos propostos

O planejamento histórico prevê abertura pelo lado avançado, sem inventário de chaves, e funcionamento nos dois sentidos após abertura. Os marcadores não implementam esses acessos. Como a topologia atual só permite mudança entre IDs sequenciais pelo controlador, e S4↔S3 e S8↔S7 já são pares adjacentes na espinha, cada atalho precisará ter percurso ou ponto de acesso distinto e utilidade demonstrável. Nenhuma economia é presumida.

| ID | Origem avançada → destino | Condição, benefício e riscos | Dependência e testes |
|---|---|---|---|
| A1 | S4 Dormitório → S3 Escadaria, com retorno | Trava de serviço proposta aberta por S4 após a primeira passagem. Reduz retorno pela subida se existir uma ligação distinta. Risco de entrar no teto ou no ciclo do pêndulo e de duplicar a porta principal | Nova trava/ligação e eventuais patamares requerem aprovação. Medir rota real antes/depois, ida/volta, morte, respawn no CP S3 e acesso a ameaças. |
| A2 | S8 Ponte → S7 Fundição, com retorno | Serviço aberto por S8 depois de alcançar lado avançado. Pode reduzir repetição dos vãos. Risco de saída sobre abismo, Comporta ou CP S7 | Definir apoios e portas fisicamente visíveis. Testar aterrissagem com corpo real, ambos sentidos, estados de ameaça e sem pular a primeira visita. |
| A3 | S11 Campanário → S9 Arquivo, com retorno | Conexão avançada proposta para retornar ao Arquivo após primeira passagem. Pode poupar parte da espinha por S10. Risco de encurtar demais a progressão e colidir com tetos, CPs ou pendência de encontro S11 | Exige nova ligação não sequencial, mecanismo de abertura e política de estado. Desenhar grafo e distâncias físicas, testar ambos sentidos, morte/reentrada e preservar acesso normal a S10. |

Persistência em sessão para travas ainda precisa de design e autorização. `states` atual registra snapshots dos setores para inimigos, mas é limpo em morte/queda. Não presumir que isso já implemente atalhos abertos de forma persistente. Decidir explicitamente se uma trava aberta sobrevive à morte ou à queda e como sobrevive ao descarregamento, sem atribuir save em disco ao capítulo. A proposta histórica sugere retenção na mesma sessão, mas requer adaptação compatível com as regras reais e aprovação.

## Distância, física e garantias de progressão

- Usar um grafo de pontos de entrada, saída, abertura e conexão, com arestas medidas por deslocamento físico real de Aren; portas entre salas não contam como deslocamento pelo espaço entre origens. Separar ida obrigatória de retorno e deduplicar ramos exclusivos.
- Com referência histórica de 17.360,42 px, uma economia conjunta hipotética de 960 px produziria 16.400,42 px, ainda acima de 12.227,52 px. Isso é apenas aritmética de orçamento. Não prova a menor rota no grafo futuro nem que 960 px seja a economia real. Calcular o menor caminho com todos os atalhos abertos e validar fisicamente. Não somar economias individuais que compartilhem trecho.
- Aren usa velocidade 100 px/s, aceleração 1.200 px/s², gravidade 680 px/s² e impulso −230 px/s. O histórico cita cerca de 70 px de alcance horizontal no mesmo nível como medida, não margem de design. Nenhum acesso proposto está comprovadamente alcançável apenas por estar próximo de um marcador. Medir partida parada, corrida, quatro aproximações, apoio integral, teto e câmera antes de aprovar coordenadas.
- Nenhum ramo deve ser necessário para finalizar a espinha, pular setores inéditos ou remover desafios obrigatórios. Preservar CPs e o fim estrutural S12. Testar carregamento modular, retorno, ameaça ativa, morte, queda e reentrada sem nós ou sinais duplicados.

## Lotes futuros, sujeitos a autorização

| Lote | Objetivo, arquivos potenciais e dependências | Aceite e evidência |
|---|---|---|
| 1 · Concepção e piloto O1 | Confirmar baseline e grafo, projetar uma descoberta simples no S2 e sua integração visual. Possíveis `chapter_sector.gd`, cenas S2, arte e testes próprios. Porta/geometria dependem de aprovação. | Dois sentidos com entrada e saída por input, pista reconhecível e distinção de Votos sem Nome. Capturas, vídeo ou sequência de frames, teste físico e avaliação do responsável antes de generalizar. |
| 2 · Ramos O2–O6 | Aplicar somente os percursos e ligações aprovados, um por vez, com arte coerente e sem modificar IA homologada. Potenciais cenas setoriais, dados de layout, composição e testes. | Extensões exclusivas medidas, acesso/retorno, sinais, obstáculos, ameaças e câmera. Avaliação jogável por lote e ajuste proporcional. |
| 3 · Atalhos A1–A3 | Depois da definição de política de trava, projetar conexões e persistência em sessão. Podem exigir `chapter.gd`, cenas, dados e testes. Alterações funcionais só após aprovação específica. | Primeira passagem não é pulada; ida e volta após abertura, sem softlock, CPs e morte/queda preservados; grafo de menor caminho e distâncias medidas. |
| 4 · Integração e entrega | Unir evidências dos lotes, testes de jornada e documentação, sem iniciar M5-F como marco. | Relatório com requisitos, distâncias, limites, regressões, checklist humano e resultados reais; homologação expressa do responsável. |

## Testes planejados e critérios de conclusão

1. Para cada descoberta, partir da espinha e executar entrada, descoberta e retorno com movimento/salto reais. Testar pistas, visualização de destino, saída acessível e interferência com inimigos e armadilhas. A aproximação em ângulos e distâncias distintas não deve exigir precisão extrema.
2. Para cada atalho, testar inacessibilidade pelo lado inicial antes da abertura, abertura pelo lado avançado, ambos os sentidos depois da abertura e comportamento declarado após descarga, morte, queda e reinício. Verificar ausência de geometria penetrada, dano inevitável, softlock e duplicações.
3. Exercitar os sete CPs, HUD e câmera nas salas afetadas, além de F6/F7 e F5. Revalidar ida e volta contínuas com ameaças ativas. Isolar ameaças apenas na medição geométrica e rotular essa fixture como tal.
4. Medir o grafo e as rotas com telemetria do personagem, distinguir extensão exclusiva de atalhos e demonstrar o menor caminho com todos abertos. O mínimo 12.227,52 px ou 12.228 px arredondado deve ser verificado pelo método escolhido e documentado.
5. Avaliar quatro resoluções nativas (1280×720, 1920×1080, 2560×1440, 3840×2160) em movimento e capturas. Repetir desempenho somente se a carga visual, quantidade de nós ou streaming justificar; documentar metodologia e picos, sem confundir com TCL física.
6. Rodar testes M0/M1/M2 e suítes da Abadia afetadas conforme os arquivos modificados, incluindo continuidade dos pilotos e estabilidade dos tetos se tocados. Preservar resultados históricos e distinguir testes não executados. Um playtest humano deve avaliar descoberta, sinalização, retorno e clareza.

Concluir M5-E requer escopo aprovado, recursos e portas efetivamente implementados, provas físicas e de progressão aprovadas, documentação e avaliação expressa do responsável. O plano de seis ramos e três atalhos pode ser ajustado somente por decisão do responsável; nenhuma métrica foi medida nesta etapa.

## Decisões pendentes e integridade

- Aprovar ou ajustar os seis ramos, seus pontos de entrada e saídas, recompensas ambientais, alvos de extensão e três atalhos antes de qualquer geometria ou mecanismo novo.
- Decidir a persistência das travas na morte, queda e reinício, mantendo explícita a ausência atual de save em disco. Definir a interface de interação ou abertura sem presumir um comando novo.
- Definir destinos fisicamente sustentados, transições secundárias e se A1/A2 geram economia real distinta da passagem principal. Validar que A3 não converta S10 em setor saltável na primeira visita.
- Confirmar que a revisão posterior da combinação avançada S11 permaneça independente da autorização M5-E, como já determinado.

Baseline desta análise: branch `main`, HEAD inicial `cda7e40b689e4e7197d2eccfb53e9fbd357032d0`. A consolidação local registrou M5-C3 em `b991268fddbf330a019b495b2222a734dc547d44` e M5-D em `a10f654f6cc4efcb2c68ede3b3254b2f09ed8d7e`. Este planejamento M5-E permanece fora desses commits; nenhuma cena ou sistema funcional foi modificado na etapa de planejamento.

## Especificação executiva para o primeiro lote futuro

**Dependência:** autorização expressa para implementar a intervenção específica; esta seção é uma proposta, não autorização nem resultado de teste. O primeiro lote propõe uma pista e uma descoberta narrativa pequena no S2, usando inicialmente os patamares opcionais já existentes do piloto. A descoberta `Votos sem Nome`, em torno de `(936,84)`, deve continuar identificável e intacta; uma eventual inscrição nova precisa ter identidade própria e não ser contabilizada como se a descoberta antiga fosse nova. A reserva `OptionalReserve` é apenas um marcador, não uma superfície nem uma entrada segura. As plataformas existentes incluem retângulos locais `(792,132,48,12)`, `(848,108,48,12)` e `(912,84,48,12)`; sua existência não comprova acesso seguro. Validar os apoios, o Monge, o checkpoint, o teto e o enquadramento antes de fixar qualquer ponto interativo.

O piloto limitado não comprova o ramo O1 completo nem seus 360 px exclusivos. A ampliação física desse ramo, portas e qualquer geometria nova continuam sujeitas a aprovação específica. Usar o mecanismo de indicação existente somente se comportar a proposta sem ocultar HUD ou mensagens importantes; caso uma interação ou interface nova seja necessária, apresentá-la para decisão antes de implementá-la.

Sequência sugerida para execução futura:

1. Registrar baseline Git, hashes protegidos e posição das plataformas, ameaças, checkpoint e câmera; preservar as alterações locais preexistentes.
2. Desenhar a pista, a recompensa narrativa e o retorno no S2, distinguindo-os da descoberta já existente; validar o projeto e obter autorização para eventuais mudanças funcionais ou estruturais.
3. Implementar somente o piloto aprovado, sem alterar IA, combate, checkpoints ou controles; manter a passagem principal e o retorno livres.
4. Testar com a física real ida e volta, aproximações diferentes, ameaça ativa, morte, queda e reentrada. Registrar separadamente medições geométricas e testes físicos; nenhum marcador isolado comprova alcançabilidade.
5. Verificar F6, F7 e F5, continuidade entre setores, HUD e câmera. Avaliar 1280×720, 1920×1080, 2560×1440 e 3840×2160 em movimento, com evidências; executar as regressões pertinentes após a última alteração.
6. Entregar relatório com mudanças, resultados reais e limitações, e solicitar playtest do responsável antes de ampliar para os demais ramos. Não declarar M5-E homologado pelo sucesso do piloto.

## Proposta de estado dos atalhos para decisão

Uma trava aberta poderia ser guardada em um estado de sessão próprio do capítulo, independente dos snapshots `states`, pois estes são limpos na morte e na queda viva. A proposta é manter a trava aberta ao trocar de sala, morrer ou sofrer queda durante a mesma sessão; F7 reiniciaria esse estado, assim como uma nova sessão do capítulo. Não há save em disco previsto. Essa política requer aprovação e testes, e não descreve uma funcionalidade já existente.

Cada atalho abriria pelo lado avançado após acesso legítimo pela rota principal, permitindo retorno nos dois sentidos depois disso. Para A3, a primeira passagem por S10 deve ser comprovada antes da abertura S11→S9, sem permitir antecipar S11 nem eliminar o acesso normal ao Jardim. A1 e A2 exigem demonstração de um percurso distinto e economia física real; não se atribui uma economia antecipada. A geometria, a ligação entre salas, os destinos, o mecanismo e o armazenamento são decisões de implementação pendentes de aprovação.

## Proposta de lote conjunto para as cinco descobertas restantes

Após avaliação do piloto pelo responsável, implementar O2–O6 em um único lote com cinco conteúdos distintos e uma infraestrutura enxuta compartilhada de indicação contextual e estado de sessão, aproveitando o padrão comprovado no S2. O lote pede autorização futura; não transforma marcadores de reserva em caminhos válidos, não autoriza automaticamente geometria adicional e não inicia os atalhos.

| Setor | Descoberta e pista proposta | Restrições a verificar no local |
|---|---|---|
| 3 | Contrapeso Partido: corrente interrompida e vestígio de sabotagem. | Varredura do pêndulo, apoio e câmera na escadaria. |
| 5 | Ossuário Submerso: inscrições e reflexo votivo, com água apenas decorativa. | Teto, Comporta, Acólito, checkpoint e volta segura. |
| 7 | Molde do Sino Mudo: marca de bronze e vestígio da fundição. | Separação do Vigia, Pêndulo, Monge e checkpoint. |
| 9 | Registro sem Assinatura: selo interrompido e fragmento narrativo. | Teto, trajeto do projétil, Jato e apoio. |
| 10 | Mirante da Abadia: abertura e vista do caminho percorrido. | Manter separação aprovada entre travessia e combate, sem novo perigo. |

Primeiro confirmar, para os cinco pontos, acessos, retorno, apoios, ameaça ativa e câmera com a geometria existente. Onde ela não permitir a experiência planejada, documentar a necessidade de geometria para decisão; não alegar que uma inscrição por proximidade implementa os comprimentos de percurso históricos. Depois integrar os cinco conteúdos de uma vez, mantendo recompensas narrativas perceptíveis e pistas com identidade própria. Executar uma suíte parametrizada que percorra fisicamente cada ponto e retorne, mais uma regressão integrada de checkpoints, carregamento e progressão; produzir uma amostra visual em movimento por setor e cobertura das quatro resoluções para a apresentação compartilhada. Registrar resultados e limitações por setor em um único relatório, seguido de um único playtest conjunto. Qualquer novo acesso, porta ou mudança estrutural requer aprovação específica; não adicionar inventário, habilidades nem atalhos neste lote.
